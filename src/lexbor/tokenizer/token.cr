# Html token without processing (raw attribute keys, html entities not converted)
struct Lexbor::Tokenizer::Token
  # :nodoc:
  getter state : Lexbor::Tokenizer::State

  # :nodoc:
  getter raw_token : Lexbor::Lib::HtmlToken

  def initialize(@state, @raw_token)
  end

  def self.from_raw(state, raw_token) : Token?
    unless raw_token.null
      Token.new(state, raw_token)
    end
  end

  # ========== token info ============

  @[AlwaysInline]
  def tag_id
    @raw_token.tag_id
  end

  @[AlwaysInline]
  def tag_sym : Symbol
    Utils::TagConverter.id_to_sym(tag_id)
  end

  # todo: tag_name

  @[AlwaysInline]
  def self_closed?
    (@raw_token.type_ & Lexbor::Lib::HtmlTokenTypeT::LXB_HTML_TOKEN_TYPE_CLOSE_SELF).to_i != 0
  end

  @[AlwaysInline]
  def closed?
    (@raw_token.type_ & Lexbor::Lib::HtmlTokenTypeT::LXB_HTML_TOKEN_TYPE_CLOSE).to_i != 0
  end

  @[AlwaysInline]
  def tag_name_slice
    buf = Lexbor::Lib.tag_name_by_id(tags, tag_id, out len)
    Slice.new(buf, len)
  end

  @[AlwaysInline]
  def tag_name
    String.new(tag_name_slice) # TODO: optimize?
  end

  # ========== token text ============

  @[AlwaysInline]
  def tag_text_slice
    begin_ = @raw_token.begin_
    Slice.new(begin_, @raw_token.end_ - begin_)
  end

  @[AlwaysInline]
  def tag_text
    String.new(tag_text_slice)
  end

  def processed_tag_text : String # tag_text with replaced entities
    str = uninitialized Lexbor::Lib::Str
    str.data = nil
    str.length = 0

    pc = uninitialized Lexbor::Lib::HtmlParserChar
    pointerof(pc).clear # nullify all fields of pc

    pc.state = ->Lexbor::Lib.html_parser_char_ref_data
    pc.mraw = Lexbor::Lib.html_tokenizer_mraw(tkz)
    pc.replace_null = true

    res = Lexbor::Lib.html_parser_char_process(pointerof(pc).as(Lexbor::Lib::HtmlParserCharT),
      pointerof(str).as(Lexbor::Lib::StrT), @raw_token.in_begin,
      @raw_token.begin_, @raw_token.end_)

    unless res == Lexbor::Lib::StatusT::LXB_STATUS_OK
      raise Lexbor::LibError.new("Failed to make data from token: #{res}")
    end

    res = String.new(str.data, str.length)

    Lexbor::Lib.str_destroy(pointerof(str).as(Lexbor::Lib::StrT), pc.mraw, false)
    res
  end

  # ========== token attributes ============

  # :nodoc:
  @attributes : Hash(String, String)?

  private def each_raw_attribute
    attr = @raw_token.attr_first

    while !attr.null?
      yield(attr)
      attr = attr.value.next
    end

    self
  end

  @[AlwaysInline]
  private def raw_key(attr)
    name_begin = attr.value.name_begin
    Slice.new(name_begin, attr.value.name_end - name_begin)
  end

  @[AlwaysInline]
  private def raw_value(attr)
    value_begin = attr.value.value_begin
    value_begin.null? ? nil : Slice.new(value_begin, attr.value.value_end - value_begin)
  end

  @[AlwaysInline]
  def any_attribute?
    !@raw_token.attr_first.null?
  end

  def each_sliced_attribute
    each_raw_attribute do |attr|
      yield(IgnoreCaseData.new(raw_key(attr)), raw_value(attr))
    end
  end

  def each_attribute
    each_sliced_attribute do |k, v|
      yield k, v ? String.new(v) : ""
    end
  end

  private def process_attribute_texts(attr)
    name = uninitialized Lexbor::Lib::Str
    name.data = nil
    name.length = 0

    value = uninitialized Lexbor::Lib::Str
    value.data = nil
    value.length = 0

    pc = uninitialized Lexbor::Lib::HtmlParserChar
    pointerof(pc).clear # nullify all fields of pc

    mraw = Lexbor::Lib.html_tokenizer_mraw(tkz)

    res = Lexbor::Lib.html_token_attr_parse(attr, pointerof(pc).as(Lexbor::Lib::HtmlParserCharT),
      pointerof(name).as(Lexbor::Lib::StrT), pointerof(value).as(Lexbor::Lib::StrT), mraw)

    unless res == Lexbor::Lib::StatusT::LXB_STATUS_OK
      raise Lexbor::LibError.new("Failed to parse token attributes: #{res}")
    end

    name_s = name.data.null? ? "" : String.new(name.data, name.length)
    value_s = value.data.null? ? "" : String.new(value.data, value.length)

    Lexbor::Lib.str_destroy(pointerof(name).as(Lexbor::Lib::StrT), mraw, false)
    Lexbor::Lib.str_destroy(pointerof(value).as(Lexbor::Lib::StrT), mraw, false)

    {name_s, value_s}
  end

  def each_processed_attribute
    each_raw_attribute do |attr|
      k, v = process_attribute_texts(attr)
      yield k, v
    end
  end

  def attribute_by(name : IgnoreCaseData)
    each_attribute do |k, v|
      return v if k == name
    end
    nil
  end

  def attribute_by(name : String)
    attribute_by IgnoreCaseData.new(name)
  end

  def attribute_by(slice : Slice)
    attribute_by IgnoreCaseData.new(slice)
  end

  def attribute_by_processed(name : String)
    each_processed_attribute do |k, v|
      return v if k == name
    end
    nil
  end

  def attributes
    @attributes ||= begin
      res = {} of String => String
      each_attribute do |k, v|
        res[k.to_s] = String.new(v)
      end
      res
    end
  end

  def attributes_processed
    @attributes ||= begin
      res = {} of String => String
      each_processed_attribute do |k, v|
        res[k.to_s] = v
      end
      res
    end
  end

  # =========== token inspect ================

  def textable?
    case tag_id
    when Lib::TagIdT::LXB_TAG__TEXT,
         Lib::TagIdT::LXB_TAG__EM_COMMENT,
         Lib::TagIdT::LXB_TAG_STYLE
      true
    else
      false
    end
  end

  #
  # Token Inspect
  #   puts token.inspect # => Lexbor::Tokenizer::Token(div, {"class" => "aaa"})
  #
  def inspect(io : IO)
    io << "Lexbor::Tokenizer::Token("
    io << '/' if closed?
    io.write(tag_name_slice)
    io << '/' if self_closed?

    if textable?
      io << ", "
      Utils::Strip.string_slice_to_io_limited(tag_text_slice, io)
    else
      _attributes = @attributes

      if _attributes || any_attribute?
        io << ", {"
        c = 0
        if _attributes
          _attributes.each do |key, value|
            io << ", " unless c == 0
            Utils::Strip.string_slice_to_io_limited(key.to_slice, io)
            io << " => "
            Utils::Strip.string_slice_to_io_limited(value.to_slice, io)
            c += 1
          end
        else
          each_sliced_attribute do |key_slice, value_slice|
            io << ", " unless c == 0
            Utils::Strip.string_slice_to_io_limited(key_slice.to_s.to_slice, io)
            io << " => "
            Utils::Strip.string_slice_to_io_limited(value_slice ? value_slice : "".to_slice, io)
            c += 1
          end
        end
        io << '}'
      end
    end

    io << ')'
  end

  def to_html(io)
    case tag_id
    when Lib::TagIdT::LXB_TAG__TEXT
      io << processed_tag_text
    when Lib::TagIdT::LXB_TAG__EM_COMMENT
      if self.closed?
        io << "-->"
      else
        io << "<!--"
      end
    else
      if self.closed?
        io << '<'
        io << '/'
        io.write(tag_name_slice)
        io << '>'
      else
        io << '<'

        io.write(tag_name_slice)

        if any_attribute?
          c = 0
          each_processed_attribute do |k, v|
            io << ' '
            io << k
            io << '='
            io << '"'
            io << v
            io << '"'
            c += 1
          end
        end

        io << '/' if self_closed?
        io << '>'
      end
    end
    self
  end

  def to_html
    String.build { |buf| to_html(buf) }
  end

  # =========== private methods ================

  # :nodoc:
  @[AlwaysInline]
  private def tkz
    @state.tokenizer.not_nil!.tkz
  end

  # :nodoc:
  @[AlwaysInline]
  private def tags
    @state.tokenizer.not_nil!.tags
  end
end

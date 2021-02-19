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
    text_start = @raw_token.text_start
    Slice.new(text_start, @raw_token.text_end - text_start)
  end

  @[AlwaysInline]
  def tag_text
    String.new(tag_text_slice)
  end

  # def processed_tag_text : String # tag_text with replaced entities
  #   str = uninitialized Lexbor::Lib::Str
  #   str.data = nil
  #   str.length = 0

  #   pc = uninitialized Lexbor::Lib::HtmlParserChar
  #   pointerof(pc).clear # nullify all fields of pc

  #   pc.state = ->Lexbor::Lib.html_parser_char_ref_data
  #   pc.mraw = Lexbor::Lib.html_tokenizer_mraw(tkz)
  #   pc.replace_null = true

  #   res = Lexbor::Lib.html_parser_char_process(pointerof(pc).as(Lexbor::Lib::HtmlParserCharT),
  #     pointerof(str).as(Lexbor::Lib::StrT), @raw_token.in_begin,
  #     @raw_token.begin_, @raw_token.end_)

  #   unless res == Lexbor::Lib::StatusT::LXB_STATUS_OK
  #     raise Lexbor::LibError.new("Failed to make data from token: #{res}")
  #   end

  #   res = String.new(str.data, str.length)

  #   Lexbor::Lib.str_destroy(pointerof(str).as(Lexbor::Lib::StrT), pc.mraw, false)
  #   res
  # end

  # ========== token attributes ============

  # :nodoc:
  @attributes : Hash(String, String)?

  private def each_raw_attribute
    attr = @raw_token.attr_first

    while !attr.null?
      yield(attr)
      attr = attr.value.next
      # break
    end

    self
  end

  @[AlwaysInline]
  private def raw_key(attr)
    p = Lib.html_token_attr_name(attr, out length)
    Slice.new(p, length)
  end

  @[AlwaysInline]
  private def raw_value(attr)
    Slice.new(attr.value.value, attr.value.value_size)
  end

  @[AlwaysInline]
  def any_attribute?
    !@raw_token.attr_first.null?
  end

  def each_sliced_attribute
    each_raw_attribute do |attr|
      yield(raw_key(attr), raw_value(attr))
    end
  end

  def each_attribute
    each_sliced_attribute do |k, v|
      yield String.new(k), String.new(v)
    end
  end

  def attribute_by(name : String)
    each_attribute do |k, v|
      return v if k == name
    end
    nil
  end

  def attribute_by(slice : Slice)
    each_sliced_attribute do |k, v|
      return String.new(v) if k == slice
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
      io << tag_text
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
          each_attribute do |k, v|
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

module Lexbor::Utils::HtmlEntities
  # !this object never freed!
  HTML_ENTITIES_NODE = begin
    doc = Lexbor::Parser.new "<div>a</div>"
    doc.nodes(:div).first.child!
  end

  def self.decode(str : String)
    HTML_ENTITIES_NODE.tag_text_set(str)
    HTML_ENTITIES_NODE.tag_text
  end

  def self.decode(bytes : Bytes)
    HTML_ENTITIES_NODE.tag_text_set(bytes)
    HTML_ENTITIES_NODE.tag_text_slice
  end

  # MRAW = begin
  #   mraw = Lexbor::Lib.mraw_create
  #   res = Lexbor::Lib.mraw_init(mraw, 1024)
  #   unless res == Lib::StatusT::LXB_STATUS_OK
  #     raise LibError.new("Failed to create mraw: #{res}")
  #   end
  #   mraw
  # end

  # def self.decode(s : String)
  #   return s if s.empty?
  #   decode(s.to_slice)
  # end

  # def self.decode(s : String)
  #   decode(s.to_slice) do |res|
  #     yield res
  #   end
  # end

  # def self.decode(slice : Slice)
  #   decode(slice) do |res|
  #     String.new(res)
  #   end
  # end

  # def self.decode(slice : Slice)
  #   str = uninitialized Lexbor::Lib::Str
  #   str.data = nil
  #   str.length = 0

  #   data = slice.to_unsafe
  #   _end = data + slice.bytesize

  #   Lib.str_init(pointerof(str).as(Lib::StrT), MRAW, slice.bytesize)
  #   if str.data == nil
  #     raise LibError.new("Failed to allocate memory")
  #   end

  #   pc = uninitialized Lexbor::Lib::HtmlParserChar
  #   pointerof(pc).clear # nullify all fields of pc

  #   pc.state = ->Lexbor::Lib.html_parser_char_ref_data
  #   pc.mraw = MRAW
  #   pc.replace_null = true

  #   while data < _end
  #     data = pc.state.call(pointerof(pc).as(Lib::HtmlParserCharT), pointerof(str).as(Lib::StrT), data, _end)
  #   end

  #   if pc.status != Lib::StatusT::LXB_STATUS_OK
  #     raise LibError.new("Failed to decode entities: #{pc.status}")
  #   end

  #   tail = uninitialized UInt8[1]
  #   tail[0] = 0
  #   tail_p = tail.to_slice.to_unsafe

  #   pc.is_eof = true
  #   data = pc.state.call(pointerof(pc).as(Lib::HtmlParserCharT), pointerof(str).as(Lib::StrT), tail_p, tail_p + 1)

  #   begin
  #     yield(Slice.new(str.data, str.length))
  #   ensure
  #     Lexbor::Lib.str_destroy(pointerof(str).as(Lexbor::Lib::StrT), MRAW, false)
  #   end
  # end
end

class Lexbor::Tokenizer
  abstract class State
    abstract def on_token(token)

    def on_begin(tokenizer); end

    def on_end; end

    getter tokenizer : Tokenizer?

    def parse(str, skip_whitespace_tokens = false)
      @tokenizer = tokenizer = Tokenizer.new(self, skip_whitespace_tokens)
      tokenizer.parse(self, str)
      self
    end

    def free
      @tokenizer.try &.free
      @tokenizer = nil
    end

    def tokenizer!
      @tokenizer.not_nil!
    end
  end

  CALLBACK = ->(tkz : Lexbor::Lib::HtmlTokenizerT, token : Lexbor::Lib::HtmlTokenT, ctx : Void*) do
    tag_id = token.value.tag_id

    unless ctx.null?
      tok = ctx.as(Lexbor::Tokenizer::State)

      if tag_id == Lexbor::Lib::TagIdT::LXB_TAG__UNDEF
        tag_id = Lexbor::Lib.html_token_tag_id_from_data(tok.tokenizer!.heap, token)
        if tag_id == Lexbor::Lib::TagIdT::LXB_TAG__UNDEF
          return Pointer(Void).null.as(Lexbor::Lib::HtmlTokenT)
        else
          token.value.tag_id = tag_id
        end
      end

      tok.on_token(Token.new(tok, token))
    end

    token
  end

  CALLBACK_WO_WHITESPACE_TOKENS = ->(tkz : Lexbor::Lib::HtmlTokenizerT, token : Lexbor::Lib::HtmlTokenT, ctx : Void*) do
    tag_id = token.value.tag_id
    if tag_id == Lexbor::Lib::TagIdT::LXB_TAG__TEXT
      begin_ = token.value.begin_
      slice = Slice.new(begin_, token.value.end_ - begin_)

      whitespaced = slice.all? &.unsafe_chr.ascii_whitespace?

      return token if whitespaced
    end

    unless ctx.null?
      tok = ctx.as(Lexbor::Tokenizer::State)
      if tag_id == Lexbor::Lib::TagIdT::LXB_TAG__UNDEF
        tag_id = Lexbor::Lib.html_token_tag_id_from_data(tok.tokenizer!.heap, token)
        if tag_id == Lexbor::Lib::TagIdT::LXB_TAG__UNDEF
          return Pointer(Void).null.as(Lexbor::Lib::HtmlTokenT)
        else
          token.value.tag_id = tag_id
        end
      end

      tok.on_token(Token.new(tok, token))
    end

    token
  end

  getter tkz, heap

  def initialize(state, @skip_whitespace_tokens = false)
    @finalized = false
    @tkz = Lexbor::Lib.html_tokenizer_create
    @heap = Lexbor::Lib.tag_heap_create

    res = Lexbor::Lib.html_tokenizer_init(@tkz)
    unless res == Lexbor::Lib::StatusT::LXB_STATUS_OK
      free
      raise LibError.new("Failed to html_tokenizer_init: #{res}")
    end

    res = Lexbor::Lib.tag_heap_init(@heap, 128)
    unless res == Lexbor::Lib::StatusT::LXB_STATUS_OK
      free
      raise LibError.new("Failed to init heap: #{res}")
    end

    Lexbor::Lib.html_tokenizer_tag_heap_set(@tkz, @heap)

    Lexbor::Lib.html_tokenizer_opt_set(@tkz, Lexbor::Lib::HtmlTokenizerOptT::LXB_HTML_TOKENIZER_OPT_WO_COPY)
    Lexbor::Lib.html_tokenizer_callback_token_done_set(@tkz, @skip_whitespace_tokens ? CALLBACK_WO_WHITESPACE_TOKENS : CALLBACK, state.as(Void*))
  end

  def parse(state, str : String)
    parse state, str.to_slice
  end

  def parse(state, slice : Slice)
    state.on_begin(self)

    res = Lexbor::Lib.html_tokenizer_begin(@tkz)
    unless res == Lexbor::Lib::StatusT::LXB_STATUS_OK
      raise LibError.new("Failed to prepare tokenizer object for parsing: #{res}")
    end

    res = Lexbor::Lib.html_tokenizer_chunk(@tkz, slice.to_unsafe, slice.bytesize)
    unless res == Lexbor::Lib::StatusT::LXB_STATUS_OK
      raise LibError.new("Failed to parse the html data: #{res}")
    end

    res = Lexbor::Lib.html_tokenizer_end(@tkz)
    unless res == Lexbor::Lib::StatusT::LXB_STATUS_OK
      raise LibError.new("Failed to ending of parsing the html data: #{res}")
    end

    state.on_end

    self
  end

  def finalize
    free
  end

  def free
    unless @finalized
      @finalized = true
      Lexbor::Lib.html_tokenizer_destroy(@tkz)
      Lexbor::Lib.tag_heap_destroy(@heap)
    end
  end
end

require "./tokenizer/*"

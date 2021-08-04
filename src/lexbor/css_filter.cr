class Lexbor::CssFilter
  Cbk = ->(node : Lib::DomElementT, spec : Void*, ctx : Void*) do
    col = ctx.as(Lexbor::Iterator::Collection)
    col << node
    Lib::StatusT::LXB_STATUS_OK
  end

  #
  # Css filter
  #   Lexbor::CssFilter.new("div.red").search_from(lexbor.body!) # => Lexbor::Iterator::Collection
  #
  def initialize(@rule : String)
    @finalized = false

    @parser = parser = Lib.css_parser_create
    status = Lib.css_parser_init(parser, nil, nil)
    if status != Lib::StatusT::LXB_STATUS_OK
      raise LibError.new("Failed to css_parser_init #{status}")
    end

    @selectors = selectors = Lib.selectors_create
    status = Lib.selectors_init(selectors)
    if status != Lib::StatusT::LXB_STATUS_OK
      raise LibError.new("Failed to selectors_init #{status}")
    end

    @list = list = Lib.css_selectors_parse(parser, rule.to_unsafe, rule.bytesize)
    if list.null?
      raise LibError.new("Failed to css_selectors_parse for #{rule.inspect}")
    end
  end

  def search_from(scope_node : Lexbor::Node)
    collection = Lexbor::Iterator::Collection.new(scope_node.parser)
    status = Lib.selectors_find(@selectors, scope_node.element, @list, Cbk, collection.as(Void*))
    if status != Lib::StatusT::LXB_STATUS_OK
      raise LibError.new("Failed to selectors_find #{status}")
    end
    collection
  end

  def free
    unless @finalized
      @finalized = true
      Lib.selectors_destroy(@selectors, true)
      Lib.css_parser_destroy(@parser, true)
      Lib.css_selector_list_destroy_memory(@list)
    end
  end

  def finalize
    free
  end

  def inspect(io)
    io << "Lexbor::CssFilter(rule: `"
    io << @rule
    io << "`)"
  end
end

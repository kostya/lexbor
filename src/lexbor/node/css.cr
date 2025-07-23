struct Lexbor::Node
  #
  # Css selector with string rule in scope on the current node
  #   return Lexbor::Iterator::Collection
  #
  # Example:
  #   some_node.css("div.red").each { |node| p node } # iterate over all divs with class `red` in the scope of node
  #
  def css(rule : String)
    filter = CssFilter.new(rule)
    css(filter)
  ensure
    filter.try &.free
  end

  #
  # Css selector with filter in scope on the current node
  #   return Lexbor::Iterator::Collection
  #
  # Example:
  #   filter = Lexbor::CssFilter.new("div.red")
  #   some_node.css(filter).each { |node| p node } # iterator over all divs with class `red` in the scope of node
  #
  def css(filter : CssFilter)
    filter.search_from(self)
  end

  #
  # Css select which yielding nodes
  #   this allows to free collection after block call and not waiting for GC
  #
  # Example:
  #   some_node.css("div.red") { |node| p node }
  #
  def css(arg)
    collection = css(arg)
    collection.each do |node|
      yield node
    end
  ensure
    collection.try &.free
  end
end

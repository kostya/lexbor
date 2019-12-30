struct Lexbor::Node
  #
  # Children iterator
  #   iterate over all node direct children, without going deeper
  #
  def children
    Iterator::Children.new(self)
  end

  #
  # Scope iterator
  #   iterate over all inner nodes of current node
  #
  def scope
    Iterator::Scope.new(self)
  end

  #
  # Walk tree
  #   similar to scope iterator, yields level and node
  #
  def walk_tree(level = 0, &block : Node, Int32 ->)
    yield self, level
    children.each { |child| child.walk_tree(level + 1, &block) }
  end

  #
  # Parents iterator
  #   iterate over all node parents, from current node to root node
  #
  def parents
    Iterator::Parents.new(self)
  end

  #
  # Left iterator
  #   iterate over all nodes from current to the root of document
  #   by moving from current to left node every time
  #
  def left_iterator
    Iterator::Left.new(self)
  end

  #
  # Right iterator
  #   iterate over all nodes from current to the end of document
  #   by moving from current to right node every time
  #
  def right_iterator
    Iterator::Right.new(self)
  end
end

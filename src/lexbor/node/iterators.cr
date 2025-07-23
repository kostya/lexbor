struct Lexbor::Node
  #
  # Children iterator
  #   iterate over all node direct children, without going deeper
  #
  def children
    Iterator::Children.new(self)
  end

  #
  # Children iterator with yield
  def children
    children.each { |node| yield node }
  end

  #
  # Scope iterator
  #   iterate over all inner nodes of current node
  #
  def scope
    Iterator::Scope.new(self)
  end

  #
  # Scope iterator with yield
  def scope
    scope.each { |node| yield node }
  end

  #
  # Walk tree
  #   similar to scope iterator, yields level and node
  #
  def walk_tree(level = 0, &block : Node, Int32 ->)
    yield self, level
    children { |child| child.walk_tree(level + 1, &block) }
  end

  #
  # Parents iterator
  #   iterate over all node parents, from current node to root node
  #
  def parents
    Iterator::Parents.new(self)
  end

  #
  # Parents iterator with yield
  def parents
    parents.each { |node| yield node }
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
  # Left iterator with yeild
  def left_iterator
    left_iterator.each { |node| yield node }
  end

  #
  # Right iterator
  #   iterate over all nodes from current to the end of document
  #   by moving from current to right node every time
  #
  def right_iterator
    Iterator::Right.new(self)
  end

  #
  # Right iterator with yeild
  def right_iterator
    right_iterator.each { |node| yield node }
  end
end

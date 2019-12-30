struct Lexbor::Iterator::Right
  include ::Iterator(Node)
  include Iterator::Filter

  @start_node : Node
  @current_node : Node? = nil

  def initialize(@start_node)
    rewind
  end

  def next
    @current_node = @current_node.not_nil!.right
    @current_node || stop
  end

  def rewind
    @current_node = @start_node
  end
end

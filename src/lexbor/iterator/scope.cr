struct Lexbor::Iterator::Scope
  include ::Iterator(Node)
  include Iterator::Filter

  @start_node : Node
  @current_node : Node
  @stop_node : Node? = nil

  def initialize(@start_node)
    @current_node = @start_node
    @stop_node = @start_node.flat_right
  end

  def next
    if (right = @current_node.right) && (right != @stop_node)
      @current_node = right
    else
      stop
    end
  end

  def rewind
    @current_node = @start_node
    @stop_node = @start_node.flat_right
  end
end

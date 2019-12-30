struct Lexbor::Iterator::Children
  include ::Iterator(Node)
  include Iterator::Filter

  @start_node : Node
  @current_node : Node?

  def initialize(@start_node)
    rewind
  end

  def next
    if cn = @current_node
      @current_node = cn.next
      cn
    else
      stop
    end
  end

  def rewind
    @current_node = @start_node.child
  end
end

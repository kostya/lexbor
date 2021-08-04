class Lexbor::Iterator::Collection
  include ::Indexable(Node)
  include Iterator::Filter

  @parser : Parser

  def initialize(@parser, initial_size = 32)
    @arr = Array(Lib::DomElementT).new(initial_capacity: initial_size)
  end

  private def unsafe_fetch(index : Int)
    node = @arr.to_unsafe[index]
    Node.new(@parser, node) # node not null here, because i always in bounds
  end

  def size
    @arr.size
  end

  def <<(element : Lib::DomElementT)
    @arr << element
  end

  def free
  end

  def inspect(io)
    io << "#<Lexbor::Iterator::Collection:0x"
    object_id.to_s(16, io)
    io << ": elements: "

    io << '['

    count = {2, size}.min
    count.times do |i|
      node_by_id(i).inspect(io)
      io << ", " unless i == count - 1
    end

    io << ", ...(#{@length - 2} more)" if @length > 2
    io << ']'

    io << '>'
  end
end

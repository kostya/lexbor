class Lexbor::Iterator::Collection
  include ::Indexable(Node)
  include Iterator::Filter

  @parser : Parser
  @length : LibC::SizeT
  @col : Lib::CollectionT

  def initialize(@parser, @col)
    @length = Lib.collection_length(@col)
    @finalized = false
  end

  private def unsafe_fetch(index : Int)
    node = Lib.collection_element(@col, index)
    Node.new(@parser, node) # node not null here, because i always in bounds
  end

  def size
    @length
  end

  def finalize
    free
  end

  def <<(element : Lib::DomElementT)
    res = Lib.collection_append(@col, element.as(Void*))
    raise LibError.new("Failed to append into collecting: #{element}") unless res == Lib::StatusT::LXB_STATUS_OK
    @length += 1
  end

  def free
    unless @finalized
      @finalized = true
      Lib.collection_destroy(@col, true)
    end
  end

  def inspect(io)
    io << "#<Lexbor::Iterator::Collection:0x"
    object_id.to_s(16, io)
    io << ": elements: "

    io << '['

    count = {2, @length}.min
    count.times do |i|
      node_by_id(i).inspect(io)
      io << ", " unless i == count - 1
    end

    io << ", ...(#{@length - 2} more)" if @length > 2
    io << ']'

    io << '>'
  end
end

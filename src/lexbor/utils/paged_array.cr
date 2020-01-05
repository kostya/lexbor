# Simple array stored in blocks of memory, faster for tokens storage
class Lexbor::Utils::PagedArray(T)
  @buf : Pointer(T)
  @buf_end : Pointer(T)
  getter bufs, block_size

  def initialize(@block_size : Int32)
    @bufs = [] of Pointer(T)

    buf = new_buffer
    @buf = buf
    @buf_end = buf + @block_size
    @bufs << buf
  end

  # current position in array
  record Pos(T), pa : PagedArray(T), buf_id : Int32, buf_start : Pointer(T), buf : Pointer(T), buf_end : Pointer(T) do
    @[AlwaysInline]
    def value
      buf.value
    end

    def next
      if @buf < @buf_end - 1
        Pos.new(@pa, @buf_id, @buf_start, @buf + 1, @buf_end)
      else
        last_id = @pa.bufs.size - 1

        if @buf_id < last_id
          _buf_id = @buf_id + 1
          _buf = @pa.bufs[_buf_id]
          if _buf_id == last_id
            Pos.new(@pa, _buf_id, _buf, _buf, @pa.@buf)
          else
            Pos.new(@pa, _buf_id, _buf, _buf, _buf + @pa.block_size)
          end
        end
      end
    end

    def prev
      if @buf > @buf_start
        Pos.new(@pa, @buf_id, @buf_start, @buf - 1, @buf_end)
      else
        if @buf_id > 0
          _buf_id = @buf_id - 1
          _buf = @pa.bufs[_buf_id]
          _buf_end = _buf + @pa.block_size
          Pos.new(@pa, _buf_id, _buf, _buf_end - 1, _buf_end)
        end
      end
    end
  end

  private def new_buffer
    Pointer(T).malloc(@block_size)
  end

  @[AlwaysInline]
  def <<(v : T)
    @buf = current_buffer
    @buf.value = v
    @buf += 1
  end

  private def current_buffer
    if @buf < @buf_end
      @buf
    else
      buf = new_buffer
      @buf_end = buf + @block_size
      @bufs << buf
      buf
    end
  end

  def elements_size
    (@bufs.size - 1) * @block_size + (@block_size - (@buf_end - @buf))
  end

  def each
    last_id = @bufs.size - 1
    @bufs.each_with_index do |buf, i|
      buf_end = (i == last_id) ? @buf : buf + @block_size
      buf_start = buf

      while buf < buf_end
        yield(Pos.new(self, i, buf_start, buf, buf_end))
        buf += 1
      end
    end
  end

  include Enumerable(Pos(T))

  def last?
    if @bufs.size == 1
      unless @bufs[0] == @buf
        Pos.new(self, @bufs.size - 1, @bufs[-1], @buf - 1, @buf)
      end
    else
      Pos.new(self, @bufs.size - 1, @bufs[-1], @buf - 1, @buf)
    end
  end

  def last
    last?.not_nil!
  end
end

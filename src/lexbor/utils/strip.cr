module Lexbor::Utils::Strip
  def self.strip_slice(slice : Bytes)
    left = slice_calc_excess_left(slice)
    right = slice_calc_excess_right(slice)
    newsize = slice.bytesize - right - left
    if newsize > 0
      Bytes.new(slice.to_unsafe + left, newsize)
    else
      Bytes.empty
    end
  end

  private def self.slice_calc_excess_right(slice : Bytes)
    i = slice.bytesize - 1
    while i >= 0 && slice[i].unsafe_chr.ascii_whitespace?
      i -= 1
    end
    slice.bytesize - 1 - i
  end

  private def self.slice_calc_excess_left(slice : Bytes)
    excess_left = 0
    while (excess_left < slice.bytesize) && slice[excess_left].unsafe_chr.ascii_whitespace?
      excess_left += 1
    end
    excess_left
  end

  def self.string_slice_to_io_limited(slice : Bytes, io : IO, max_size = 30)
    io << '"'
    if slice.bytesize > max_size
      io.write Bytes.new(slice.to_unsafe, max_size)
      io << "..."
    else
      io.write slice
    end
    io << '"'
  end
end

require "./spec_helper"

describe Lexbor::Utils::PagedArray do
  it "work" do
    a = Lexbor::Utils::PagedArray(Int32).new(3)
    10.times { |i| a << i }

    a.map(&.value).to_a.should eq (0...10).to_a
  end

  [2, 13, 182, 1999].each do |block_size|
    [0, 1, 2, block_size - 1, block_size, block_size + 1, block_size + 2, block_size * 2 - 2, block_size * 2 - 1, block_size * 2,
     block_size * 2 + 1, block_size * 2 + 2, block_size / 2, block_size / 2 - 1, block_size / 2 + 1,
     block_size * 2 + block_size / 2 - 1, block_size * 2 + block_size / 2, block_size * 2 + block_size / 2 + 1,
     block_size * 2 + block_size / 2 + 2, rand(1000)].each do |el_count|
      context "#{block_size}:#{el_count}" do
        a = Lexbor::Utils::PagedArray(Int32).new(block_size)
        el_count.times { |i| a << i }

        it "each" do
          a.map(&.value).to_a.should eq (0...el_count).to_a
        end

        it "elements_size" do
          a.elements_size.should eq el_count
        end

        it "first" do
          a.first?.try(&.value).should eq(el_count == 0 ? nil : 0)
        end

        it "last" do
          a.last?.try(&.value).should eq(el_count == 0 ? nil : el_count - 1)
        end

        it "iterate from first to end" do
          res = [] of Int32
          if pos = a.first?
            res << pos.value
            while pos = pos.next
              res << pos.value
            end
          end

          res.should eq (0...el_count).to_a
        end

        it "iterate from last to first" do
          res = [] of Int32
          if pos = a.last?
            res << pos.value
            while pos = pos.prev
              res << pos.value
            end
          end

          res.should eq (0...el_count).to_a.reverse
        end
      end
    end
  end
end

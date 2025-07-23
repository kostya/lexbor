require "./node"

module Lexbor::Iterator
  module Filter
    #
    # Iterator node filter
    #   returns Lexbor::Iterator::Collection
    #
    #   iterator.nodes(Lexbor::Lib::TagIdT::LXB_TAG_DIV).each { |node| ... }
    #
    def nodes(tag_id : Lib::TagIdT)
      self.select { |node| node.tag_id == tag_id }
    end

    #
    # Iterator node filter
    #   returns Lexbor::Iterator::Collection
    #
    #   iterator.nodes(:div).each { |node| ... }
    #
    def nodes(tag_sym : Symbol)
      nodes(Utils::TagConverter.sym_to_id(tag_sym))
    end

    #
    # Iterator node filter
    #   returns Lexbor::Iterator::Collection
    #
    #   iterator.nodes("div").each { |node| ... }
    #
    def nodes(tag_str : String)
      nodes(Utils::TagConverter.string_to_id(tag_str))
    end

    #
    # Node filter with yield
    #   iterator.nodes("div") { |node| ... }
    #
    def nodes(filter)
      nodes(filter).each do |node|
        yield node
      end
    end
  end
end

require "./iterator/*"

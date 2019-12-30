require "./spec_helper"

record ALink, before : String?, href : String?, anchor : String?, after : String?

def extract_link(node)
  anchor = node.child.try &.tag_text.strip
  href = node.attribute_by("href")

  # closure check node for non empty text
  text_tag = ->(n : Lexbor::Node) do
    if n.is_text?
      slice = n.tag_text_slice
      return if slice.size == 0
      !String.new(slice).each_char.all?(&.whitespace?) && n.parents.all?(&.visible?)
    end
  end

  before = node.left_iterator.find(&text_tag).try(&.tag_text.strip)
  after = (node.child || node).right_iterator.find(&text_tag).try(&.tag_text.strip)

  ALink.new before, href, anchor, after
end

def find_first_good_text(iterator)
  iterator
    .select(&.is_text?)
    .select(&.parents.all? { |n| n.visible? && !n.object? })
    .map(&.tag_text.strip)
    .reject(&.empty?)
    .first?
end

def extract_links2(parser)
  parser.nodes(:a).map do |node|
    anchor = node.child.try &.tag_text.strip
    href = node.attribute_by("href")
    before = find_first_good_text(node.left_iterator)
    after = find_first_good_text((node.child || node).right_iterator)
    ALink.new before, href, anchor, after
  end
end

def parser_links
  str = <<-HTML
    <html>
      <div>
        Before
        <br>
        <a href='/link1'>Link1</a>
        <br>
        After
      </div>

      #
      <a href='/link2'>Link2</a>
      --

      <div>some<span>⬠ ⬡ ⬢</span></div>
      <a href='/link3'>Link3</a>
      <script>asdf</script>
      <span>⬣ ⬤ ⬥ ⬦</span>

      <a href='/link4'></a>
    </html>
  HTML

  Lexbor::Parser.new(str)
end

describe "integration" do
  it "parse links" do
    res = [] of ALink
    parser_links.nodes(:a).each { |node| res << extract_link(node) }
    res.size.should eq 4
    link1, link2, link3, link4 = res

    link1.should eq ALink.new("Before", "/link1", "Link1", "After")
    link2.should eq ALink.new("#", "/link2", "Link2", "--")
    link3.should eq ALink.new("⬠ ⬡ ⬢", "/link3", "Link3", "⬣ ⬤ ⬥ ⬦")
    link4.should eq ALink.new("⬣ ⬤ ⬥ ⬦", "/link4", nil, nil)
  end

  it "parse links, chained iterators" do
    res = extract_links2(parser_links).to_a
    res.size.should eq 4
    link1, link2, link3, link4 = res

    link1.should eq ALink.new("Before", "/link1", "Link1", "After")
    link2.should eq ALink.new("#", "/link2", "Link2", "--")
    link3.should eq ALink.new("⬠ ⬡ ⬢", "/link3", "Link3", "⬣ ⬤ ⬥ ⬦")
    link4.should eq ALink.new("⬣ ⬤ ⬥ ⬦", "/link4", nil, nil)
  end
end

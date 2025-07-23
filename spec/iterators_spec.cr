require "./spec_helper"

def parser(**args)
  str = <<-HTML
    <html>
      <div>
        <table>
          <tr>
            <td></td>
            <td>Bla</td>
          </tr>
        </table>
        <a>text</a>
      </div>
      <br>
      <span>
        <div>
          Text
        </div>
      </span>
    </html>
  HTML

  parser = Lexbor.new(str, **args)
  parser
end

INSPECT_NODE = ->(node : Lexbor::Node) {
  s = ""
  if node.is_text?
    s += "(" + node.tag_text.strip + ")|" if !node.tag_text.strip.empty?
  else
    s += node.tag_name
    s += "|"
  end
  s
}

describe "iterators" do
  it "right_iterator" do
    res = parser.root!.right_iterator.map(&INSPECT_NODE).join
    res.should eq "head|body|div|table|tbody|tr|td|td|(Bla)|a|(text)|br|span|div|(Text)|"
  end

  it "scope from html is equal to right_iterator" do
    res = parser.root!.scope.map(&INSPECT_NODE).join
    res.should eq "head|body|div|table|tbody|tr|td|td|(Bla)|a|(text)|br|span|div|(Text)|"
  end

  it "scope with yield" do
    s = ""
    parser.root!.scope { |n| s += INSPECT_NODE.call(n) }
    s.should eq "head|body|div|table|tbody|tr|td|td|(Bla)|a|(text)|br|span|div|(Text)|"
  end

  it "right_iterator from middle" do
    node = parser.nodes(:td).first # td
    res = node.right_iterator.map(&INSPECT_NODE).join
    res.should eq "td|(Bla)|a|(text)|br|span|div|(Text)|"
  end

  it "right_iterator from middle with yield" do
    node = parser.nodes(:td).first # td
    s = ""
    node.right_iterator { |n| s += INSPECT_NODE.call(n) }
    s.should eq "td|(Bla)|a|(text)|br|span|div|(Text)|"
  end

  it "right_iterator from last" do
    node = parser.nodes(:_text).to_a.last # text
    res = node.right_iterator.map(&INSPECT_NODE).join
    res.should eq ""
  end

  it "right_iterator with nodes filter" do
    res = parser.root!.right_iterator.nodes(:_text).map(&INSPECT_NODE).join
    res.should eq "(Bla)|(text)|(Text)|"
  end

  it "left_iterator" do
    node = parser.nodes(:_text).to_a.last # text
    res = node.left_iterator.map(&INSPECT_NODE).join
    res.should eq "(Text)|div|span|br|(text)|a|(Bla)|td|td|tr|tbody|table|div|body|head|html|"
  end

  it "left_iterator with yield" do
    node = parser.nodes(:_text).to_a.last # text
    res = node.left_iterator.map(&INSPECT_NODE).join
    res.should eq "(Text)|div|span|br|(text)|a|(Bla)|td|td|tr|tbody|table|div|body|head|html|"
  end

  pending "left_iterator with another tree_options" do
    parser = parser()                     # (tree_options: Lexbor::Lib::LexborTreeParseFlags::MyHTML_TREE_PARSE_FLAGS_SKIP_WHITESPACE_TOKEN | Lexbor::Lib::LexborTreeParseFlags::MyHTML_TREE_PARSE_FLAGS_WITHOUT_DOCTYPE_IN_TREE)
    node = parser.nodes(:_text).to_a.last # text
    s = ""
    node.left_iterator { |n| s += INSPECT_NODE.call(n) }
    s.should eq "div|span|br|(text)|a|(Bla)|td|td|tr|tbody|table|div|body|head|html|"
  end

  it "left_iterator from middle" do
    node = parser.nodes(:br).first # br
    res = node.left_iterator.map(&INSPECT_NODE).join
    res.should eq "(text)|a|(Bla)|td|td|tr|tbody|table|div|body|head|html|"
  end

  it "left_iterator from root" do
    res = parser.root!.left_iterator.map(&INSPECT_NODE).join
    res.should eq ""
  end

  it "left_iterator with nodes filter" do
    node = parser.nodes(:_text).to_a.last # text
    res = node.left_iterator.nodes(:_text).map(&INSPECT_NODE).join
    res.should eq "(Text)|(text)|(Bla)|"
  end

  it "walk_tree" do
    str = [] of String
    parser.root!.walk_tree do |node|
      str << INSPECT_NODE.call(node)
    end
    str.join("").should eq "html|head|body|div|table|tbody|tr|td|td|(Bla)|a|(text)|br|span|div|(Text)|"
  end

  it "scope from div" do
    div = parser.nodes(:div).first
    res = div.scope.map(&INSPECT_NODE).join
    res.should eq "table|tbody|tr|td|td|(Bla)|a|(text)|"
  end

  it "iterator tags on other iterator" do
    div = parser.nodes(:div).first
    res = div.scope.nodes(:_text).map(&.tag_text.strip).reject(&.empty?).to_a
    res.should eq %w(Bla text)
  end

  it "iterator works with string tags" do
    div = parser.nodes(:div).first
    res = div.scope.nodes("_text").map(&.tag_text.strip).reject(&.empty?).to_a
    res.should eq %w(Bla text)
  end

  it "collection iterator" do
    res = parser.nodes(:div).map(&INSPECT_NODE).join
    res.should eq "div|div|"
  end

  it "collection iterator empty" do
    res = parser.nodes(:area).map(&INSPECT_NODE).join
    res.should eq ""
  end

  # questionable
  # it "collection iterator with nodes filter (usefull for css subfiltering)" do
  #   res = parser.nodes(:div).nodes(:div).map(&INSPECT_NODE).join
  #   res.should eq "div|div|"
  # end

  it "collection iterator inspect" do
    parser.css("div").inspect.should contain "elements: [Lexbor::Node(:div), Lexbor::Node(:div)]>"
  end

  pending "collection iterator inspect" do
    parser # (tree_options: Lexbor::Lib::LexborTreeParseFlags::MyHTML_TREE_PARSE_FLAGS_SKIP_WHITESPACE_TOKEN | Lexbor::Lib::LexborTreeParseFlags::MyHTML_TREE_PARSE_FLAGS_WITHOUT_DOCTYPE_IN_TREE)
      .nodes(:_text).inspect.should contain "elements: [Lexbor::Node(:_text, \"Bla\"), Lexbor::Node(:_text, \"text\"), ...(1 more)]>"
  end

  it "children iterator" do
    res = parser.body!.children.map(&INSPECT_NODE).join
    res.should eq "div|br|span|"
  end

  it "children iterator with nodes filter" do
    res = parser.body!.children.nodes(:div).map(&INSPECT_NODE).join
    res.should eq "div|"
  end

  it "children iterator with yield" do
    s = ""
    parser.body!.children { |n| s += INSPECT_NODE.call(n) }
    s.should eq "div|br|span|"
  end

  it "parents iterator" do
    node = parser.nodes(:_text).find { |n| n.tag_text == "Bla" }.not_nil!
    res = node.parents.map(&INSPECT_NODE).join
    res.should eq "td|tr|tbody|table|div|body|html|"
  end

  it "parents iterator with nodes filter" do
    node = parser.nodes(:_text).find { |n| n.tag_text == "Bla" }.not_nil!
    res = node.parents.nodes(:div).map(&INSPECT_NODE).join
    res.should eq "div|"
  end

  it "parents iterator with yield" do
    node = parser.nodes(:_text).find { |n| n.tag_text == "Bla" }.not_nil!
    s = ""
    node.parents { |n| s += INSPECT_NODE.call(n) }
    s.should eq "td|tr|tbody|table|div|body|html|"
  end

  it "nodes call with block" do
    texts = [] of String
    parser.nodes(:div) do |node|
      texts << node.inner_text.strip
    end
    texts.should eq ["Bla\n" + "        \n" + "      \n" + "      text", "Text"]
  end

  it "nodes call with block from node" do
    texts = [] of String
    parser.nodes(:span).first.nodes(:div) do |node|
      texts << node.inner_text.strip
    end
    texts.should eq ["Text"]
  end

  it "nodes call with block from node" do
    texts = [] of String
    parser.nodes(:span).first.scope.nodes(:div) do |node|
      texts << node.inner_text.strip
    end
    texts.should eq ["Text"]
  end

  # it "Collection befave like array, when multiple times call size, empty? and others..." do
  #   parser = Lexbor.new(%q{<head><title>Title</title></head>})
  #   iter = parser.css("title")

  #   iter.size.should eq 1
  #   iter.empty?.should eq false
  #   iter.size.should eq 1
  #   iter.empty?.should eq false
  #   iter.size.should eq 1
  #   iter.empty?.should eq false
  # end
end

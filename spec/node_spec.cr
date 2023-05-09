require "./spec_helper"

describe Lexbor::Node do
  it "node from root" do
    parser = Lexbor::Parser.new("<html><body><div class=AAA style='color:red' chk>Haha</div></body></html>")

    node = parser.root!.child!.next!.child!
    node.tag_name.should eq "div"
    node.attributes.should eq({"class" => "AAA", "style" => "color:red", "chk" => ""})
    node.tag_id.should eq Lexbor::Lib::TagIdT::LXB_TAG_DIV
    node.tag_sym.should eq :div
    node.child!.tag_text.should eq "Haha"
    node.attribute_by("class").should eq "AAA"
    node.attribute_by("class".to_slice).should eq "AAA".to_slice
    node.attribute_by("asfasdf").should eq nil
    node.attribute_by("asfasdf".to_slice).should eq nil
  end

  it "raise error when no node" do
    parser = Lexbor::Parser.new("<html><body><div class=AAA style='color:red'>Hahasdfjasdfladshfasldkfhadsfkdashfaklsjdfhalsdfdsafsda</div></body></html>")
    node = parser.root!.child!.next!.child!.child!
    expect_raises(Lexbor::EmptyNodeError, /'child' called from Lexbor::Node/) { node.child! }
  end

  it "attributes" do
    parser = Lexbor::Parser.new("<html><body><div class=AAA style='color:red'>Haha</div></body></html>")

    node = parser.root!.child!.next!.child!
    node.attributes.should eq({"class" => "AAA", "style" => "color:red"})
    node.attribute_by("class").should eq "AAA"
    node["class"].should eq("AAA")
    node.attribute_by("class".to_slice).should eq "AAA".to_slice
    node.has_key?("class").should be_true
    node.has_key?("id").should be_false
    node["class"]?.should eq("AAA")
    node["id"]?.should be_nil
    node.fetch("class", "").should eq("AAA")
    node.fetch("id", "").should eq("")
  end

  it "add attribute" do
    parser = Lexbor::Parser.new("<html><body><div class=\"foo\">Haha</div></body></html>")

    node = parser.nodes(:div).first
    node.attribute_add("id", "bar")
    node["bla"] = ""
    node["bla2"] = "2"
    node.attributes.should eq({"class" => "foo", "id" => "bar", "bla" => "", "bla2" => "2"})
  end

  it "add attribute if attributes was cached" do
    parser = Lexbor::Parser.new("<html><body><div class=\"foo\">Haha</div></body></html>")

    node = parser.nodes(:div).first
    node.attributes.should eq({"class" => "foo"})
    node.attribute_add("id", "bar")
    node.attributes.should eq({"class" => "foo", "id" => "bar"})
  end

  it "remove attribute" do
    parser = Lexbor::Parser.new("<html><body><div class=\"foo\" id=\"bar\">Haha</div></body></html>")

    node = parser.nodes(:div).first
    node.attribute_remove("id")
    node.attributes.should eq({"class" => "foo"})

    node.attribute_remove("unkown")
    node.attributes.should eq({"class" => "foo"})
  end

  it "remove attribute by alias" do
    parser = Lexbor::Parser.new("<html><body><div class=\"foo\" id=\"bar\">Haha</div></body></html>")

    node = parser.nodes(:div).first
    node.attribute_remove("id")
    node.attributes.should eq({"class" => "foo"})

    node["unkown"] = nil
    node.attributes.should eq({"class" => "foo"})
  end

  it "remove attribute if attributes was cached" do
    parser = Lexbor::Parser.new("<html><body><div class=\"foo\" id=\"bar\">Haha</div></body></html>")

    node = parser.nodes(:div).first
    node.attributes.should eq({"class" => "foo", "id" => "bar"})

    node.attribute_remove("id")
    node.attributes.should eq({"class" => "foo"})

    node.attribute_remove("unkown")
    node.attributes.should eq({"class" => "foo"})
  end

  it "remove single attribue, #12" do
    html = %Q{<a href="/3">3</a>}
    parser = Lexbor::Parser.new(html)
    node = parser.nodes(:a).first
    node["href"] = ""
    node.attributes.should eq({"href" => ""})
  end

  it "ignore case attributes" do
    parser = Lexbor::Parser.new("<html><body><div Class=AAA STYLE='color:red'>Haha</div></body></html>")

    node = parser.root!.child!.next!.child!
    node.attributes.should eq({"class" => "AAA", "style" => "color:red"})
    node.attribute_by("class").should eq "AAA"
  end

  it "children" do
    parser = Lexbor::Parser.new("<html><body><div class=AAA style='color:red'>Haha</div><span></span></body></html>")

    node = parser.root!.child!.next!
    node1, node2 = node.children.to_a
    node1.tag_name.should eq "div"
    node2.tag_name.should eq "span"
  end

  it "each_child" do
    parser = Lexbor::Parser.new("<html><body><div class=AAA style='color:red'>Haha</div><span></span></body></html>")

    node = parser.root!.child!.next!
    nodes = [] of Lexbor::Node
    node.children.each { |ch| nodes << ch }
    node1, node2 = nodes
    node1.tag_name.should eq "div"
    node2.tag_name.should eq "span"
  end

  it "each_child iterator" do
    parser = Lexbor::Parser.new("<html><body><div class=AAA style='color:red'>Haha</div><span></span></body></html>")

    node = parser.root!.child!.next!
    node1, node2 = node.children.to_a
    node1.tag_name.should eq "div"
    node2.tag_name.should eq "span"
  end

  it "parents" do
    parser = Lexbor::Parser.new("<html><body><div class=AAA style='color:red'>Haha</div><span></span></body></html>")

    node = parser.root!.right_iterator.to_a.last
    parents = node.parents.to_a
    parents.size.should eq 2
    node1, node2 = parents
    node1.tag_name.should eq "body"
    node2.tag_name.should eq "html"
  end

  it "each_parent" do
    parser = Lexbor::Parser.new("<html><body><div class=AAA style='color:red'>Haha</div><span></span></body></html>")

    node = parser.root!.right_iterator.to_a.last
    parents = [] of Lexbor::Node
    node.parents.each { |ch| parents << ch }
    parents.size.should eq 2
    node1, node2 = parents
    node1.tag_name.should eq "body"
    node2.tag_name.should eq "html"
  end

  it "each_parent iterator" do
    parser = Lexbor::Parser.new("<html><body><div class=AAA style='color:red'>Haha</div><span></span></body></html>")

    node = parser.root!.right_iterator.to_a.last
    parents = node.parents.to_a
    parents.size.should eq 2
    node1, node2 = parents
    node1.tag_name.should eq "body"
    node2.tag_name.should eq "html"
  end

  it "visible?" do
    parser = Lexbor::Parser.new("<body><style>bla</style></body>")
    node = parser.root!.right_iterator.to_a[-2]
    node.tag_name.should eq "style"
    node.visible?.should eq false

    parser = Lexbor::Parser.new("<body><div>bla</div></body>")
    node = parser.root!.right_iterator.to_a[-2]
    node.tag_name.should eq "div"
    node.visible?.should eq true
  end

  it "object?" do
    parser = Lexbor::Parser.new("<body><object>bla</object></body>")
    node = parser.root!.right_iterator.to_a[-2]
    node.tag_name.should eq "object"
    node.object?.should eq true
    node.child!.object?.should eq false
  end

  it "is_tag_div?" do
    parser = Lexbor::Parser.new("<div>1</div>")
    noindex = parser.root!.right_iterator.to_a[-2]
    noindex.tag_name.should eq "div"
    noindex.is_tag_div?.should eq true
    noindex.child!.is_tag_div?.should eq false
  end

  it "is_tag_noindex?" do
    parser = Lexbor::Parser.new("<noindex>1</noindex>")
    noindex = parser.root!.right_iterator.to_a[-2]
    noindex.tag_name.should eq "noindex"
    noindex.is_tag_noindex?.should eq true
    noindex.child!.is_tag_noindex?.should eq false

    parser = Lexbor::Parser.new("<NOINDEX>1</NOINDEX>")
    noindex = parser.root!.right_iterator.to_a[-2]
    noindex.tag_name.should eq "noindex"
    noindex.is_tag_noindex?.should eq true
    noindex.child!.is_tag_noindex?.should eq false
  end

  it "remove!" do
    html_string = "<html><body><div id='first'>Haha</div><div id='second'>Hehe</div><div id='third'>Hoho</div></body></html>"
    id_array = %w(first second third)
    (0..2).each do |i|
      parser = Lexbor::Parser.new html_string
      parser.root!.child!.next!.children.to_a[i].remove!
      parser.root!.child!.next!.children.to_a.map(&.attribute_by("id")).should(
        eq id_array.dup.tap(&.delete_at(i))
      )
    end
  end

  it "remove! bug" do
    html = <<-HTML
      <!DOCTYPE html>
      <html>
        <head>
          <meta charset="utf-8">
          <title>Example</title>
        </head>
        <body><!-- foo --> <!-- bar --> <!-- baz --></body>
      </html>
    HTML
    lexbor = Lexbor::Parser.new html
    nodes = lexbor.nodes(:_em_comment)
    nodes.to_a.each &.remove!
    lexbor.body!.to_html.should eq "<body>  \n  </body>"
  end

  # it "get set data" do
  #   parser = Lexbor::Parser.new("<body><object>bla</object></body>")
  #   node = parser.body!

  #   str = "bla"

  #   node.data = str.as(Void*)

  #   body2 = parser.root!.child!.next!
  #   body2.data.as(String).should eq str

  #   parser.root!.data.null?.should eq true
  # end

  describe "#append_child" do
    it "adds a node at the end" do
      tree = Lexbor::Parser.new ""
      parent = tree.create_node(:div)
      child = tree.create_node(:a)
      grandchild = tree.create_node(:span)

      parent.append_child(child)
      child.append_child(grandchild)

      parent.to_html.should eq("<div><a><span></span></a></div>")
      child.to_html.should eq "<a><span></span></a>"
      parent.children.first.tag_sym.should eq(:a)
      child.children.first.tag_sym.should eq(:span)
    end
  end

  describe "#insert_before" do
    it "adds a node just prior to this node" do
      document = Lexbor::Parser.new("<html><body><main></main></body></html>")
      main = document.nodes("main").first
      header = document.create_node(:header)

      main.insert_before(header)

      body_html = "<body><header></header><main></main></body>"
      document.body!.to_html.should eq body_html
    end
  end

  describe "#insert_after" do
    it "adds a node just following this node" do
      html_string = "<html><body><header></header></body></html>"
      document = Lexbor::Parser.new(html_string)
      header = document.nodes("header").first
      main = document.create_node(:main)

      header.insert_after(main)

      body_html = "<body><header></header><main></main></body>"
      document.body!.to_html.should eq body_html
    end
  end

  describe "#inner_text=" do
    it "add inner_text" do
      document = Lexbor::Parser.new("<html><body><div></div></body></html>")
      div = document.nodes("div").first
      div.inner_text = "bla"
      document.to_html.should eq "<html><head></head><body><div>bla</div></body></html>"
    end

    it "add inner_text with redefine" do
      document = Lexbor::Parser.new("<html><body><div>hoho</div></body></html>")
      div = document.nodes("div").first
      div.inner_text = "bla"
      document.to_html.should eq "<html><head></head><body><div>bla</div></body></html>"
    end

    it "add inner_text with redefine inner nodes even" do
      document = Lexbor::Parser.new("<html><body><div><span>hoho</span></div></body></html>")
      div = document.nodes("div").first
      div.inner_text = "bla"
      document.to_html.should eq "<html><head></head><body><div>bla</div></body></html>"
    end
  end

  describe "inner_html=" do
    it "parse" do
      document = Lexbor::Parser.new("<html><body><div></div></body></html>")
      div = document.nodes("div").first
      div.inner_html = "<a HREF=#>bla</a>"
      document.to_html.should eq "<html><head></head><body><div><a href=\"#\">bla</a></div></body></html>"
    end

    it "parse template" do
      document = Lexbor::Parser.new("<html><body><div></div></body></html>")
      div = document.nodes("div").first
      div.inner_html = "<TEMPLATE>Test</template>"
      document.to_html.should eq "<html><head></head><body><div><template>Test</template></div></body></html>"
    end

    it "create node and add inner html" do
      doc = Lexbor::Parser.new ""
      div = doc.create_node(:div)
      div.inner_html = "<TEMPLATE>Test</template>"
      div.to_html.should eq "<div><template>Test</template></div>"
    end
  end

  describe "inner_html" do
    it "render inner_html of the node" do
      doc = Lexbor::Parser.new %q{<div><a href="#">Link</a><p>Read this</p></div>}
      t = doc.nodes(:div).first
      t.inner_html.should eq "<a href=\"#\">Link</a><p>Read this</p>"
    end

    it "render inner_pretty_html of the node" do
      t = <<-TEXT
        <div class="AAA" style="color:red">
          Haha
          <span>
            11
          </span>
        </div>
      TEXT

      doc = Lexbor::Parser.new(t)
      t = doc.nodes(:div).first
      t.inner_pretty_html.should eq "\nHaha\n<span>\n  11\n</span>"
    end
  end

  context "to_html" do
    it "deep" do
      parser = Lexbor::Parser.new("<html><body><div class=AAA style='color:red'>Haha <span>11</span></div></body></html>")
      node = parser.nodes(:div).first
      node.to_html.should eq %Q[<div class="AAA" style="color:red">Haha <span>11</span></div>]
    end

    it "flat" do
      parser = Lexbor::Parser.new("<html><body><div class=AAA style='color:red'>Haha <span>11</span></div></body></html>")
      node = parser.nodes(:div).first
      node.to_html(deep: false).should eq %Q[<div class="AAA" style="color:red">]
    end

    it "deep io" do
      parser = Lexbor::Parser.new("<html><body><div class=AAA style='color:red'>Haha <span>11</span></div></body></html>")
      node = parser.nodes(:div).first
      io = IO::Memory.new
      node.to_html(io)
      io.rewind
      io.gets_to_end.should eq %Q[<div class="AAA" style="color:red">Haha <span>11</span></div>]
    end

    it "flat io" do
      parser = Lexbor::Parser.new("<html><body><div class=AAA style='color:red'>Haha <span>11</span></div></body></html>")
      node = parser.nodes(:div).first
      io = IO::Memory.new
      node.to_html(io, deep: false)

      io.rewind
      io.gets_to_end.should eq %Q[<div class="AAA" style="color:red">]
    end

    it "deep not serialize next node" do
      parser = Lexbor::Parser.new("<html><body><div class=AAA style='color:red'>Haha <span>11</span></div><div>Jopa</div></body></html>")
      node = parser.nodes(:div).first
      node.to_html.should eq %Q[<div class="AAA" style="color:red">Haha <span>11</span></div>]
    end
  end

  context "to_pretty_html" do
    it "work" do
      parser = Lexbor::Parser.new("<html><body><div class=AAA style='color:red'>Haha <span>11</span></div></body></html>")
      node = parser.nodes(:div).first
      t = <<-TEXT
      <div class="AAA" style="color:red">
        Haha
        <span>
          11
        </span>
      </div>
      TEXT
      node.to_pretty_html.should eq t.gsub("\r\n", "\n")
    end

    it "work, not serialize next node" do
      parser = Lexbor::Parser.new("<html><body><div class=AAA style='color:red'>Haha <span>11</span></div><div>Jopa</div></body></html>")
      node = parser.nodes(:div).first
      t = <<-TEXT
      <div class="AAA" style="color:red">
        Haha
        <span>
          11
        </span>
      </div>
      TEXT
      node.to_pretty_html.should eq t.gsub("\r\n", "\n")
    end

    it "work" do
      parser = Lexbor::Parser.new(%Q{<html><body><style>color:red;</style><script>\nsome();\n</script><div class=AAA style='color:red'>Haha \nbla<span>11<hr/>   12<img src="bla.png"></span><!--hah--></div></body></html>})
      node = parser.nodes(:body).first
      t = <<-TEXT
      <body>
        <style>
          color:red;
        </style>
        <script>
          some();
        </script>
        <div class="AAA" style="color:red">
          Haha
          bla
          <span>
            11
            <hr>
            12
            <img src="bla.png">
          </span>
          <!--hah-->
        </div>
      </body>
      TEXT
      node.to_pretty_html.should eq t.gsub("\r\n", "\n")
    end

    it "work" do
      text = <<-BLA
      <html>
      <head>    </head>
      <body>      <a href="bla"  >    </a>  <a href="bla2"  >   j </a> </body>

      </html>
      BLA

      parser = Lexbor::Parser.new(text)
      t = <<-TEXT
      <html>
        <head></head>
        <body>
          <a href="bla"></a>
          <a href="bla2">
            j
          </a>
        </body>
      </html>
      TEXT
      parser.to_pretty_html.should eq t.gsub("\r\n", "\n")
    end

    it "not damaging html" do
      lxb1 = Lexbor::Parser.new(PAGE25) # , encoding: Lexbor::Lib::MyEncodingList::MyENCODING_WINDOWS_1251)
      s1 = lxb1.to_pretty_html

      lxb2 = Lexbor::Parser.new(s1)
      s2 = lxb2.to_pretty_html

      File.open("./saved_s1.html", "w") { |f| f.puts s1 }
      File.open("./saved_s2.html", "w") { |f| f.puts s2 }

      unless s1 == s2
        raise "Failed to compare htmls, run `vimdiff ./saved_s1.html ./saved_s2.html`"
      else
        1.should eq 1
      end
    end

    it "with doctype" do
      text = <<-BLA
      <!doctype html>
      <html>
      bla
      </html>
      BLA

      parser = Lexbor::Parser.new(text)
      t = "<!DOCTYPE html>\n<html>\n  <head></head>\n  <body>\n    bla\n  </body>\n</html>"
      parser.to_pretty_html.should eq t
    end
  end

  context "inner_text" do
    it do
      parser = Lexbor::Parser.new("<html><body>1<div class=AAA style='color:red'>Haha<span>11</span>bla</div> 2 </body></html>")
      parser.body!.inner_text(join_with: ' ').should eq "1 Haha 11 bla 2"
      parser.body!.inner_text(join_with: ' ', deep: false).should eq "1 2"
    end

    it do
      parser = Lexbor::Parser.new("<html><div>bla<b>11</b>12</div></html>")
      parser.nodes(:div).first.inner_text(join_with: ' ').should eq "bla 11 12"
    end

    it do
      parser = Lexbor::Parser.new("<html><div>bla<b>11</b>12</div></html>")
      parser.nodes(:div).first.inner_text(join_with: '-').should eq "bla-11-12"
    end

    it do
      parser = Lexbor::Parser.new("<html><div>bla<b>11</b>12</div></html>")
      parser.nodes(:div).first.inner_text(join_with: "").should eq "bla1112"
    end

    it do
      parser = Lexbor::Parser.new("<html><div>bla<b>11</b>12</div></html>")
      parser.nodes(:div).first.inner_text(join_with: "==").should eq "bla==11==12"
    end

    it do
      parser = Lexbor::Parser.new("<html><div><b>11</b> </div></html>")
      parser.nodes(:div).first.inner_text(join_with: ' ').should eq "11 "
    end

    it do
      parser = Lexbor::Parser.new("<html><body>1<div class=AAA style='color:red'>Haha<span>11</span>bla</div> 2 </body></html>")
      parser.body!.inner_text(join_with: nil).should eq "1Haha11bla 2 "
      parser.body!.inner_text(join_with: nil, deep: false).should eq "1 2 "
    end

    it do
      parser = Lexbor::Parser.new("<html><body>1<div class=AAA style='color:red'>Haha<span>11</span>bla</div> 2 </body></html>")
      parser.nodes(:div).first.inner_text.should eq "Haha11bla"
      parser.nodes(:div).first.inner_text(deep: false).should eq "Hahabla"
    end

    it do
      parser = Lexbor::Parser.new("<html><body>1<div class=AAA style='color:red'>Haha<span>11</span>bla</div> 2 </body></html>")
      parser.nodes(:span).first.inner_text.should eq "11"
      parser.nodes(:span).first.inner_text(deep: false).should eq "11"
    end
  end

  context "inspect" do
    context "work" do
      parser = Lexbor::Parser.new(%Q[<html><body><div class=AAA style='color:red'>Haha <span>11<a href="#" class="AAA">jopa</a></span></div>
        <div>#{"bla" * 30}</div></body></html>])

      it do
        node = parser.nodes(:div).first
        node.inspect.should eq "Lexbor::Node(:div, {\"class\" => \"AAA\", \"style\" => \"color:red\"})"
      end

      it do
        node = parser.nodes(:div).first
        node.attributes
        node.inspect.should eq "Lexbor::Node(:div, {\"class\" => \"AAA\", \"style\" => \"color:red\"})"
      end

      it do
        node = parser.nodes(:div).first
        node.child!.inspect.should eq "Lexbor::Node(:_text, \"Haha \")"
      end

      it do
        node = parser.nodes(:span).first
        node.inspect.should eq "Lexbor::Node(:span)"
      end

      it do
        node = parser.nodes(:div).to_a[1]
        node.child!.inspect.should eq "Lexbor::Node(:_text, \"blablablablablablablablablabla...\")"
      end
    end
  end

  pending "self_closed?" do
    it { Lexbor::Parser.new(%Q[<html><body><hr/></body></html>]).nodes(:hr).first.self_closed?.should eq true }
    it { Lexbor::Parser.new(%Q[<html><body><div></div></body></html>]).nodes(:div).first.self_closed?.should eq false }
  end

  it "attributes not crashed on text nodes, fixed #5" do
    page = fixture("failed_text_attrs.htm")
    Lexbor::Parser.new(page).root!.scope.each { |n| n.attributes["checked"]? }
  end

  it "attributes not crashed on doctype nodes, fixed #5" do
    page = <<-PAGE
    <!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01//EN" "http://www.w3.org/TR/html4/strict.dtd">
    PAGE
    Lexbor::Parser.new(page).document!.scope.each { |n| n.attributes["checked"]? }
  end

  it "tag_name of special nodes should be correct" do
    parser = Lexbor::Parser.new("<!doctype html><html><body><div>bla</div><!--blah--></body></html>")

    text = parser.nodes(:div).first.child!
    text.tag_sym.should eq :_text
    text.tag_name.should eq "_text"

    doctype = parser.document!.child!
    doctype.tag_sym.should eq :_em_doctype
    doctype.tag_name.should eq "_em_doctype"

    comment = parser.nodes(:_em_comment).first
    comment.tag_sym.should eq :_em_comment
    comment.tag_name.should eq "_em_comment"
  end
end

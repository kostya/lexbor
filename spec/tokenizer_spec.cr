require "./spec_helper"

class CounterA < Lexbor::Tokenizer::State
  @text : String?
  @input_text : Bytes?
  @attrs = Hash(String, String).new
  @c = 0
  @tag_name : String?
  @html_token : String?
  @insp : String?

  def on_token(token)
    if token.tag_sym == :a && !token.closed?
      @c += 1

      @tag_name = token.tag_name

      token.each_attribute do |key, value|
        @attrs[key.to_s] = value
      end

      @insp = token.inspect
      @html_token = token.to_html
    elsif token.tag_sym == :_text && @c > 0
      @text = token.tag_text
      @input_text = token.tag_text_input_slice
    end
  end
end

class Inspecter < Lexbor::Tokenizer::State
  getter res

  def initialize
    @res = [] of String
  end

  def on_token(token)
    @res << token.inspect
  end
end

CONT1 = <<-HTML
  <!doctype html>
  <html>
    <head>
      <title>title</title>
    </head>
    <body>
      <script>
        console.log("js");
      </script>
      <div class=red>
        <!--comment-->
        <br/>
        <a HREF="/href">link &amp; lnk</a>
        <style>
          css. red
        </style>
      </div>
    </body>
  </html>
HTML

INSPECT_TOKENS = ["Lexbor::Tokenizer::Token(!doctype, {\"html\" => \"\"})",
                  "Lexbor::Tokenizer::Token(html)",
                  "Lexbor::Tokenizer::Token(head)",
                  "Lexbor::Tokenizer::Token(title)",
                  "Lexbor::Tokenizer::Token(#text, \"title\")", # TODO: change to _text?
                  "Lexbor::Tokenizer::Token(/title)",
                  "Lexbor::Tokenizer::Token(/head)",
                  "Lexbor::Tokenizer::Token(body)",
                  "Lexbor::Tokenizer::Token(script)",
                  "Lexbor::Tokenizer::Token(#text, \"\n        console.log(\"js\");\n  ...\")",
                  "Lexbor::Tokenizer::Token(/script)",
                  "Lexbor::Tokenizer::Token(div, {\"class\" => \"red\"})",
                  "Lexbor::Tokenizer::Token(!--, \"comment\")", # TODO: better tag name?
                  "Lexbor::Tokenizer::Token(br/)",
                  "Lexbor::Tokenizer::Token(a, {\"href\" => \"/href\"})", # TODO: downcase href?
                  "Lexbor::Tokenizer::Token(#text, \"link & lnk\")",
                  "Lexbor::Tokenizer::Token(/a)",
                  "Lexbor::Tokenizer::Token(style, \"\")",
                  "Lexbor::Tokenizer::Token(#text, \"\n" + "          css. red\n" + "        \")",
                  "Lexbor::Tokenizer::Token(/style, \"\")",
                  "Lexbor::Tokenizer::Token(/div)",
                  "Lexbor::Tokenizer::Token(/body)",
                  "Lexbor::Tokenizer::Token(/html)",
                  "Lexbor::Tokenizer::Token(#end-of-file)"]

def parse_doc
  Lexbor::Tokenizer::Collection.new.parse(CONT1)
end

def a_counter(str)
  CounterA.new.parse(str)
end

class ToHtml < Lexbor::Tokenizer::State
  getter res

  def initialize
    @res = ""
  end

  def on_token(token)
    unless token.tag_id == Lexbor::Lib::TagIdT::LXB_TAG__END_OF_FILE
      @res += token.to_html + "|"
    end
  end
end

def tokenizer_to_html(html)
  ToHtml.new.parse(html).@res
end

class Hrefs < Lexbor::Tokenizer::State
  getter hrefs = Array(String).new

  def on_token(token)
    if token.tag_id == Lexbor::Lib::TagIdT::LXB_TAG_A && !token.closed?
      if href = token.attribute_by("href")
        hrefs << href
      end
    end
  end
end

describe Lexbor::Tokenizer do
  context "Basic usage" do
    it "count" do
      counter = a_counter("<div><span>test</span><a href=bla>bla</a><br/></div>")
      counter.@c.should eq 1
    end

    it "find correct tag_name" do
      counter = a_counter("<div><span>test</span><A href=bla>bla &amp; ho</a><br/></div>")
      counter.@tag_name.should eq "a"
    end

    it "find correct processed text" do
      counter = a_counter("<div><span>test</span><a href=bla>bla &amp; ho</a><br/></div>")
      counter.@text.should eq "bla & ho"
      String.new(counter.@input_text.not_nil!).should eq "bla &amp; ho"
    end

    it "use global tags lxb_heap, but not a problem to call many times" do
      1000.times do
        counter = a_counter("<div><span>test</span><a href=bla>bla</a><br/></div>")
        counter.@c.should eq 1
        counter.free
      end
    end

    it "find correct raw attributes" do
      counter = a_counter("<div><span>test</span><a href=bla CLASS='ho&#81' what ho=>bla &amp; ho</a><br/></div>")
      counter.@attrs.should eq({"href" => "bla", "class" => "hoQ", "what" => "", "ho" => ""})
    end

    it "inspect" do
      counter = a_counter("<div><span>test</span><a href=bla CLASS='ho&#81' what ho=>bla &amp; ho</a><br/></div>")
      counter.@insp.should eq "Lexbor::Tokenizer::Token(a, {\"href\" => \"bla\", \"class\" => \"hoQ\", \"what\" => \"\", \"ho\" => \"\"})"
    end

    it "to_html" do
      counter = a_counter("<div><span>test</span><a href=bla CLASS='ho&#81' what ho=>bla &amp; ho</a><br/></div>")
      counter.@html_token.should eq "<a href=\"bla\" class=\"hoQ\" what=\"\" ho=\"\">"
    end
  end

  context "inspecter" do
    it "work for Tokenizer" do
      counter = Inspecter.new.parse(CONT1)
      counter.res.size.should eq 39
    end

    it "work for Tokenizer with whitespace filter" do
      counter = Inspecter.new.parse(CONT1, true)
      counter.res.size.should eq 24
      counter.res.should eq INSPECT_TOKENS
    end
  end

  context "to_html" do
    it { tokenizer_to_html("<body><a href='#'>bla</a></body>").should eq "<body>|<a href=\"#\">|bla|</a>|</body>|" }
    it { tokenizer_to_html("<script><!--comm</script><span></span>").should eq "<script>|<!--comm|</script>|<span>|</span>|" }
    it { tokenizer_to_html("<script> document.write('<a>ho</a>'); </script><span></span>").should eq "<script>| document.write('<a>ho</a>'); |</script>|<span>|</span>|" }
    it { tokenizer_to_html("<style> .css res <a></a> </style><span></span>").should eq "<style>| .css res <a></a> |</style>|<span>|</span>|" }
    it { tokenizer_to_html("<textarea> .css res <a></a> </textarea><span></span>").should eq "<textarea>| .css res <a></a> |</textarea>|<span>|</span>|" }
  end

  context "bug with svg" do
    it "without ws" do
      counter = Hrefs.new.parse(PAGE_SVG)
      counter.hrefs.should eq(["/bla"])
    end

    it "with ws" do
      counter = Hrefs.new.parse(PAGE_SVG, true)
      counter.hrefs.should eq(["/bla"])
    end
  end
end

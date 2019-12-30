# Example: print html tokens using sax parser

require "../src/lexbor"

str = if filename = ARGV[0]?
        File.read(filename, "UTF-8", invalid: :skip)
      else
        <<-HTML
          <body>
            <a href="/link1">Link1</a>
            <a class=red HREF="/link2">Link2</a>
          </body>
        HTML
      end

class Doc < Lexbor::SAX::Tokenizer
  def on_token(token)
    p token
  end
end

doc = Doc.new
parser = Lexbor::SAX.new(doc)
parser.parse(str)

# Output:
# Lexbor::SAX::Token(body)
# Lexbor::SAX::Token(a, {"href" => "/link1"})
# Lexbor::SAX::Token(-text, "Link1")
# Lexbor::SAX::Token(/a)
# Lexbor::SAX::Token(a, {"class" => "red", "href" => "/link2"})
# Lexbor::SAX::Token(-text, "Link2")
# Lexbor::SAX::Token(/a)
# Lexbor::SAX::Token(/body)
# Lexbor::SAX::Token(-end-of-file)

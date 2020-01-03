# Example: print html tokens using tokenizer

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

class Doc < Lexbor::Tokenizer::State
  def on_token(token)
    p token
  end
end

Doc.new.parse(str, skip_whitespace_tokens: true)

# Output:
# Lexbor::Tokenizer::Token(body)
# Lexbor::Tokenizer::Token(a, {"href" => "/link1"})
# Lexbor::Tokenizer::Token(#text, "Link1")
# Lexbor::Tokenizer::Token(/a)
# Lexbor::Tokenizer::Token(a, {"class" => "red", "href" => "/link2"})
# Lexbor::Tokenizer::Token(#text, "Link2")
# Lexbor::Tokenizer::Token(/a)
# Lexbor::Tokenizer::Token(/body)
# Lexbor::Tokenizer::Token(#end-of-file)

# Example: print html tree

require "../src/lexbor"

def walk(node, level = 0)
  puts "#{" " * level * 2}#{node.inspect}"
  node.children.each { |child| walk(child, level + 1) }
end

str = if filename = ARGV[0]?
        File.read(filename, "UTF-8", invalid: :skip)
      else
        "<html><Div><span class='test'>HTML</span></div></html>"
      end

parser = Lexbor::Parser.new(str)
walk(parser.root!)

# Output:
# Lexbor::Node(:html)
#   Lexbor::Node(:head)
#   Lexbor::Node(:body)
#     Lexbor::Node(:div)
#       Lexbor::Node(:span, {"class" => "test"})
#         Lexbor::Node(:_text, "HTML")

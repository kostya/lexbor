# Example: how to parse fragment of html

require "../src/lexbor"

str = if filename = ARGV[0]?
        File.read(filename, "UTF-8", invalid: :skip)
      else
        <<-HTML
        <html>
          <div>
          </div>
        </html>
        HTML
      end

doc = Lexbor.new(str)
div = doc.nodes(:div).first
div.inner_html = "<a href='/bla'><span>blah &amp;</a>" # it also fixed not-closed tags like <span>
puts doc.to_pretty_html

# Output:
# <html>
#   <head></head>
#   <body>
#     <div>
#       <a href="/bla">
#         <span>
#           blah &
#         </span>
#       </a>
#     </div>
#   </body>
# </html>

# Example: basic usage

require "../src/lexbor"

html = <<-HTML
  <html>
    <body>
      <div id="t1" class="red">
        <a href="/#">O_o</a>
      </div>
      <div id="t2"></div>
    </body>
  </html>
HTML

lexbor = Lexbor::Parser.new(html)

lexbor.nodes(:div).each do |node|
  id = node["id"]?

  if first_link = node.scope.nodes(:a).first?
    href = first_link["href"]?
    link_text = first_link.inner_text

    puts "div with id #{id} have link [#{link_text}](#{href})"
  else
    puts "div with id #{id} have no links"
  end
end

# Output:
#   div with id t1 have link [O_o](/#)
#   div with id t2 have no links

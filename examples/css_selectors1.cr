require "../src/lexbor"

html = <<-HTML
  <html>
    <body>
      <table id="t1">
        <tr><td>Hello</td></tr>
      </table>
      <table id="t2">
        <tr><td>123</td><td>other</td></tr>
        <tr><td>foo</td><td>columns</td></tr>
        <tr><td>bar</td><td>are</td></tr>
        <tr><td>xyz</td><td>ignored</td></tr>
      </table>
    </body>
  </html>
HTML

lexbor = Lexbor.new(html)

p lexbor.css("#t2 tr td:first-child").map(&.inner_text).to_a
# => ["123", "foo", "bar", "xyz"]

lexbor.css("#t2 tr td:first-child") do |node|
  puts node.to_html
end
# => <td>123</td>
# => <td>foo</td>
# => <td>bar</td>
# => <td>xyz</td>

lexbor.css("#t2 tr") do |node|
  node.css("td:first-child") do |node2|
    puts node2.to_html
  end
end
# => <td>123</td>
# => <td>foo</td>
# => <td>bar</td>
# => <td>xyz</td>

# Example: extract links and around texts from html

require "../src/lexbor"

str = if filename = ARGV[0]?
        File.read(filename, "UTF-8", invalid: :skip)
      else
        <<-HTML
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
        </html>
        HTML
      end

def good_texts_iterator(iterator)
  iterator
    .nodes(:_text)
    .select(&.parents.all? { |n| n.visible? && !n.object? })
    .map(&.tag_text.strip)
    .reject(&.empty?)
end

Lexbor::Parser.new(str).nodes(:a).each do |node|
  anchor = node.inner_text(deep: true)
  href = node.attribute_by("href")
  before = good_texts_iterator(node.left_iterator).first?
  after = good_texts_iterator((node.child || node).right_iterator).first?
  puts "(#{before}) <#{href}>(#{anchor}) (#{after})"
end

# Output:
#   (Before) </link1>(Link1) (After)
#   (#) </link2>(Link2) (--)
#   (⬠ ⬡ ⬢) </link3>(Link3) (⬣ ⬤ ⬥ ⬦)

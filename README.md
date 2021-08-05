# Lexbor

[![Build Status](https://github.com/kostya/lexbor/actions/workflows/ci.yml/badge.svg)](https://github.com/kostya/lexbor/actions/workflows/ci.yml?query=branch%3Amaster+event%3Apush)

Fast HTML5 Parser with CSS selectors (based on new lexborisov's HTML5 parser [lexbor](https://github.com/lexbor/lexbor)). This is successor of [myhtml](https://github.com/kostya/myhtml) and expected to be faster and use less memory. Usage is almost equal to myhtml.

## Installation


Add this to your application's `shard.yml`:

```yaml
dependencies:
  lexbor:
    github: kostya/lexbor
```

And run `shards install` (Installation require `cmake`, make sure it installed)


## Usage example

```crystal
require "lexbor"

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
  id = node.attribute_by("id")

  if first_link = node.scope.nodes(:a).first?
    href = first_link.attribute_by("href")
    link_text = first_link.inner_text

    puts "div with id #{id} have link [#{link_text}](#{href})"
  else
    puts "div with id #{id} have no links"
  end
end

# Output:
#   div with id t1 have link [O_o](/#)
#   div with id t2 have no links
```

## Css selectors example

```crystal
require "lexbor"

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

lexbor = Lexbor::Parser.new(html)

p lexbor.css("#t2 tr td:first-child").map(&.inner_text).to_a
# => ["123", "foo", "bar", "xyz"]

p lexbor.css("#t2 tr td:first-child").map(&.to_html).to_a
# => ["<td>123</td>", "<td>foo</td>", "<td>bar</td>", "<td>xyz</td>"]
```

## More Examples

[examples](https://github.com/kostya/lexbor/tree/master/examples)

## Development Setup:

```shell
git clone https://github.com/kostya/lexbor.git
cd lexbor
make
crystal spec
```

## Benchmark

Parse google results page(600Kb) 1000 times, and 5000 times css select.

[lexbor-program](https://github.com/kostya/lexbor/tree/master/bench/test-lexbor.cr)
[myhtml-program](https://github.com/kostya/lexbor/tree/master/bench/test-myhtml.cr)
[crystagiri-program](https://github.com/kostya/lexbor/tree/master/bench/test-libxml.cr)
[nokogiri-program](https://github.com/kostya/lexbor/tree/master/bench/test-libxml.rb)

| Lang     | Lib                 | Parse time, s | Css time, s | Memory, MiB |
| -------- | ------------------- | ------------- | ----------- | ----------- |
| Crystal  | lexbor              | 2.48          | 0.48        | 8.8         |
| Crystal  | myhtml(+modest)     | 3.13          | 0.77        | 11.7        |
| Ruby 2.7 | Nokogiri(libxml2)   | 9.44          | 54.70       | 148.7       |
| Crystal  | Crystagiri(libxml2) | 11.90         | -           | 25.1        |


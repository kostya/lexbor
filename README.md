# Lexbor

[![Build Status](https://github.com/kostya/lexbor/actions/workflows/ci.yml/badge.svg)](https://github.com/kostya/lexbor/actions/workflows/ci.yml?query=branch%3Amaster+event%3Apush)

Fast HTML5 Parser with CSS selectors (based on lexborisov's HTML5 parser [lexbor](https://github.com/lexbor/lexbor)). This is successor of [myhtml](https://github.com/kostya/myhtml) and expected to be faster and use less memory. Usage is almost equal to myhtml.

## Installation

Install dependency cmake:

    sudo apt install cmake

Add this to your application's `shard.yml`:

```yaml
dependencies:
  lexbor:
    github: kostya/lexbor
```

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

Parse google results page(800Kb) 1000 times, and 5000 times css select.

[lexbor-program](https://github.com/kostya/lexbor/tree/master/bench/test-lexbor.cr)
[myhtml-program](https://github.com/kostya/lexbor/tree/master/bench/test-myhtml.cr)
[crystagiri-program](https://github.com/kostya/lexbor/tree/master/bench/test-libxml.cr)
[nokogiri-program](https://github.com/kostya/lexbor/tree/master/bench/test-libxml.rb)

Running on Ryzen 3800x.
| Lang     | Lib                 | Parse time, s | Css time, s | Memory, MiB |
| -------- | ------------------- | ------------- | ----------- | ----------- |
| Ruby 2.7 | Nokolexbor(lexbor)  | 2.47          | 1.44        | 107.7       |
| Crystal  | lexbor              | 2.95          | 0.62        | 9.6         |
| Crystal  | myhtml(+modest)     | 3.75          | 0.96        | 11.4        |
| Crystal  | Crystagiri(libxml2) | 8.82          | -           | 23.5        |
| Ruby 2.7 | Nokogiri(libxml2)   | 11.05         | 52.19       | 166.2       |

Running on Apple M1.
| Lang     | Lib                 | Parse time, s | Css time, s | Memory, MiB |
| -------- | ------------------- | ------------- | ----------- | ----------- |
| Crystal  | lexbor              | 1.80          | 0.47        | 24.5        |
| Ruby 2.7 | Nokolexbor(lexbor)  | 2.27          | 0.97        | 232.6       |
| Crystal  | myhtml(+modest)     | 2.90          | 0.64        | 20.7        |
| Ruby 2.7 | Nokogiri(libxml2)   | 11.74         | 50.62       | 207.6       |
| Crystal  | Crystagiri(libxml2) | 32.77         | -           | 17.4        |


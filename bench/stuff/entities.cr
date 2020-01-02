require "../../src/lexbor"

def str(i = 0)
  "Entities: &#x54;&#x72;&#x79;&#x20;&#x65;&#x6e;&#x74;&#x69;&#x74;&#x69;&#x65;&#x73;&excl;, and some manual: &#61 &amp - &amp; bla -- #{i}&Auml;"
end

N = (ARGV[0]? || 100000).to_i

p str
p Lexbor.decode_html_entities(str)

t = Time.now
s = 0
N.times do |i|
  s += Lexbor.decode_html_entities(str(i)).bytesize
end
p s
p Time.now - t

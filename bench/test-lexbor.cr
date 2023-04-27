require "lexbor"

page = File.read("./google.html")

t = Time.local
1000.times do
  lxb = Lexbor::Parser.new(page)
  lxb.free
end
p Time.local - t

t = Time.local
s = 0
links = [] of String
lxb = Lexbor::Parser.new(page)
5000.times do
  links = lxb.css(%Q<div.g a[data-ved][href]:not([href="#"])>).map(&.attribute_by("href")).to_a
  s += links.size
end
p links.last?
p s
p Time.local - t

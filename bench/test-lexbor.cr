require "lexbor"

page = File.read("./google.html")

t = Time.local
1000.times do
  myhtml = Lexbor::Parser.new(page)
  myhtml.free
end
p Time.local - t

t = Time.local
s = 0
links = [] of String
myhtml = Lexbor::Parser.new(page)
1000.times do
  links = myhtml.css(%Q<div.g a[data-ved][href]:not([href="#"])>).map(&.attribute_by("href")).to_a
  s += links.size
end
p links.last?
p s
p Time.local - t

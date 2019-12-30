require "myhtml"

page = File.read("./google.html")

t = Time.now
1000.times do
  myhtml = Myhtml::Parser.new(page)
  myhtml.free
end
p Time.now - t

t = Time.now
s = 0
links = [] of String
myhtml = Myhtml::Parser.new(page)
1000.times do
  links = myhtml.css("div.g h3.r a").map(&.attribute_by("href")).to_a
  s += links.size
end
p links.last
p s
p Time.now - t

require "crystagiri"

page = File.read("./google.html")

t = Time.local
1000.times do
  Crystagiri::HTML.new page
end
p Time.local - t

t = Time.local
s = 0
links = [] of String
doc = Crystagiri::HTML.new page
1000.times do
  doc.css(%Q<div.g a[data-ved][href]:not([href="#"])>) { |tag| links << tag.node["href"].not_nil! }
  s += links.size
end
p links.last?
p s
p Time.local - t

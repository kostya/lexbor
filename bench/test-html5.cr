require "html5"

page = File.read("./google.html")

t = Time.local
1000.times do
  doc = HTML5.parse(page)
end
p Time.local - t

t = Time.local
s = 0
links = [] of String
doc = HTML5.parse(page)
5000.times do
  links = doc.css(%Q<div.g a[data-ved][href]:not([href="#"])>).map(&.[]("href")).to_a
  s += links.size
end
p links.last?
p s
p Time.local - t

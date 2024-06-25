require "xml"

page = File.read("./google.html")

t = Time.local
1000.times do
  XML.parse_html(page)
end
p Time.local - t

t = Time.local
s = 0
links = [] of String
5000.times do
  # links = myhtml.css(%Q<div.g a[data-ved][href]:not([href="#"])>).map(&.attribute_by("href")).to_a
  # s += links.size
end
p links.last?
p s
p Time.local - t

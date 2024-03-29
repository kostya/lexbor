require "bundler/setup"
require "nokolexbor"

page = File.read("./google.html")

t = Time.now
1000.times do
  doc = Nokolexbor::HTML(page)
end
p Time.now - t

t = Time.now
s = 0
links = []
doc = Nokolexbor::HTML(page)
5000.times do
  links = doc.css(%Q<div.g a[data-ved][href]:not([href="#"])>).map { |link| link["href"] }
  s += links.size
end
p links.last
p s
p Time.now - t

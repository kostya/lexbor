require "bundler/setup"
require "nokogiri"

page = File.read("./google.html")

t = Time.now
1000.times do
  doc = Nokogiri::HTML(page)
end
p Time.now - t

t = Time.now
s = 0
links = []
doc = Nokogiri::HTML(page)
1000.times do
  links = doc.css("div.g h3.r a").map { |link| link["href"] }
  s += links.size
end
p links.last
p s
p Time.now - t

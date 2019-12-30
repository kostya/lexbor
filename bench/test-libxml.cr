require "crystagiri"

page = File.read("./google.html")

t = Time.now
1000.times do
  Crystagiri::HTML.new page
end
p Time.now - t

t = Time.now
s = 0
links = [] of String
doc = Crystagiri::HTML.new page
1000.times do
  doc.css("div.g h3.r a") { |tag| links << tag.node["href"].not_nil! }
  s += links.size
end
p links.last
p s
p Time.now - t

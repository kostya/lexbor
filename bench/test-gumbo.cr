require "gumbo-crystal"

page = File.read("./google.html")

t = Time.local
1000.times do
  output = Gumbo::Output.new LibGumbo.gumbo_parse page
  output.uninitialize # wrapper deinit
end
p Time.local - t

t = Time.local
s = 0
links = [] of String
output = Gumbo::Output.new LibGumbo.gumbo_parse page
1000.times do
  # links = myhtml.css("div.g h3.r a").map(&.attribute_by("href")).to_a
  # s += links.size
end
p links.last?
p s
p Time.local - t

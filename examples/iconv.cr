# Example: iconv replacement, faster!!!
#   iconv 1.html cp1251 utf-8

require "../src/lexbor"

filename = ARGV[0]
from = (ARGV[1]? || "UTF-8")
to = (ARGV[2]? || "UTF-8")

file_io = File.open(filename)

ec = Lexbor::EncodingConverter.new(from, to)
ec.convert(file_io) { |slice| STDOUT.write(slice) }

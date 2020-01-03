# Example: iconv replacement
#   iconv -f cp1251 1.html

require "../src/lexbor"

filename = nil
from = "UTF-8"
to = "UTF-8"
replace = ""
help = false

while arg = ARGV.shift?
  if arg == "-f"
    from = ARGV.shift
  elsif arg == "-t"
    to = ARGV.shift
  elsif arg == "-r"
    replace = ARGV.shift
  elsif arg == "-h"
    help = true
  else
    filename = arg
  end
end

if help
  puts "Usage:"
  puts "  iconv [-f FROM] [-t TO] [FILENAME]"
  puts "  Example: "
  puts "    iconv -f cp1251 1.html"
  puts "    cat file | iconv -f cp1251"
  exit 1
end

# normalize user input, to encoding name
fromv = Lexbor::Utils::DetectEncoding.assoc_encoding_with_additionals(from)
raise "Unknown encoding from #{from}" unless fromv
tov = Lexbor::Utils::DetectEncoding.assoc_encoding_with_additionals(to)
raise "Unknown encoding to #{tov}" unless tov

io = filename ? File.open(filename, "r") : STDIN
STDERR.puts("converting #{filename} from #{fromv} to #{tov}")

ec = Lexbor::EncodingConverter.new(fromv, tov, buffer_size: 20 * 1024, replace_str: replace)
ec.convert(io) { |slice| STDOUT.write(slice) }

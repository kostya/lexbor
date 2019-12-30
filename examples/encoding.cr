require "../src/lexbor"

# This page encoded in windows-1251
page = File.read("./spec/fixtures/25.htm")

# by default page parsed as UTF-8
lexbor = Lexbor::Parser.new(page)
p lexbor.encoding                     # => MyENCODING_DEFAULT
p lexbor.nodes(:div).first.inner_text # => "\xC7\xE0\xE3\xF0\xF3\xE7\xEA\xE0...

# set encoding directly
lexbor = Lexbor::Parser.new(page, encoding: Lexbor::Lib::MyEncodingList::MyENCODING_WINDOWS_1251)
p lexbor.encoding                     # => MyENCODING_WINDOWS_1251
p lexbor.nodes(:div).first.inner_text # => "Загрузка. Пожалуйста, подождите..."

# set encoding from header
encoding = Lexbor::Utils::DetectEncoding.from_header?("text/html; charset=Windows-1251")
lexbor = Lexbor::Parser.new(page, encoding: encoding)
p lexbor.encoding                     # => MyENCODING_WINDOWS_1251
p lexbor.nodes(:div).first.inner_text # => "Загрузка. Пожалуйста, подождите..."

# try to find encoding from <meta charset=...>
lexbor = Lexbor::Parser.new(page, detect_encoding_from_meta: true)
p lexbor.encoding                     # => MyENCODING_WINDOWS_1251
p lexbor.nodes(:div).first.inner_text # => "Загрузка. Пожалуйста, подождите..."

# try to detect encoding by trigrams (slow, and not 100% correct)
lexbor = Lexbor::Parser.new(page, detect_encoding: true)
p lexbor.encoding                     # => MyENCODING_WINDOWS_1251
p lexbor.nodes(:div).first.inner_text # => "Загрузка. Пожалуйста, подождите..."

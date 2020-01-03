# Example: Helper to detect encoding and convert html page to UTF-8
#   using header, meta tag

require "../src/lexbor"

page1 = %Q{<head><meta charset="windows-1251"></head><body>\xEF\xF0\xE8\xE2\xE5\xF2</body>}
page2 = %Q{<body>\xEF\xF0\xE8\xE2\xE5\xF2</body>}

# by default it trying to find encoding from <meta> tag
res = Lexbor::Utils::DetectEncoding.html_detect_encoding_and_convert(page1)
p "meta tag: #{res.inspect}"
# => "meta tag: {LXB_ENCODING_WINDOWS_1251, :meta, \"<head><meta charset=\\\"windows-1251\\\"></head><body>привет</body>\", []}"

# extract encoding from content_type header
res = Lexbor::Utils::DetectEncoding.html_detect_encoding_and_convert(page1, content_type: "text/html; charset='Windows-1251' ")
p "content_type: #{res.inspect}"
# => "content_type: {LXB_ENCODING_WINDOWS_1251, :header, \"<head><meta charset=\\\"windows-1251\\\"></head><body>привет</body>\", []}"

# convert page from known encoding
res = Lexbor::Utils::DetectEncoding.html_detect_encoding_and_convert(page1, from: "CP1251")
p "from: #{res.inspect}"
# => "from: {LXB_ENCODING_WINDOWS_1251, :from, \"<head><meta charset=\\\"windows-1251\\\"></head><body>привет</body>\", []}"

# when no encoding found, use default
res = Lexbor::Utils::DetectEncoding.html_detect_encoding_and_convert(page2, default: "CP1251")
p "default: #{res.inspect}"
# => "default: {LXB_ENCODING_WINDOWS_1251, :default, \"<body>привет</body>\", []}"

# detect encoding by all params with priorities
res = Lexbor::Utils::DetectEncoding.html_detect_encoding_and_convert(page1, default: "CP1251", content_type: "text/html; charset='Windows-1251' ")
p "use all: #{res.inspect}"
# => "use all: {LXB_ENCODING_WINDOWS_1251, :header, \"<head><meta charset=\\\"windows-1251\\\"></head><body>привет</body>\", []}"

res = Lexbor::Utils::DetectEncoding.html_detect_encoding_and_convert(page2, default: "CP1251", content_type: "text/html; charset='Windows-1251' ")
p "use all: #{res.inspect}"
# => "use all: {LXB_ENCODING_WINDOWS_1251, :header, \"<body>привет</body>\", []}"

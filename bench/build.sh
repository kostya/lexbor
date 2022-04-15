curl -L -s 'https://www.google.com/search?client=firefox-b-d&q=html+parsers&num=100' -A 'Mozilla/5.0 (Windows NT 10.0; Win64; x64; rv:79.0) Gecko/20100101 Firefox/79.0' > google.html
bundle
shards install --ignore-crystal-version
crystal build test-libxml.cr --release -o bin_test_libxml --no-debug
crystal build test-myhtml.cr --release -o bin_test_myhtml --no-debug
crystal build test-lexbor.cr --release -o bin_test_lexbor --no-debug
#crystal build test-gumbo.cr --release -o bin_test_gumbo --no-debug
crystal build test-html5.cr --release -o bin_test_html5 --no-debug
crystal build test-crystal.cr --release -o bin_test_crystal --no-debug

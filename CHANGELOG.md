## 3.6.4
* put lexbor.c into the rep, to avoid downloading

## 3.6.3
* build_ext.cr check checksum for lxb.c, thanks: @philipp-classen
* build_ext.cr use Http::Client, thanks: @philipp-classen

## 3.6.2
* update liblexbor v3.0.0

## 3.6.1
* Fix windows builds

## 3.6.0
* [PROBABLY BREAKING CHANGE] remove cmake dependency, use amalgation build.

## 3.5.0
* update liblexbor to version 2.7.0

## 3.4.2
* fix bug with `to_pretty_html` with one symbol text
* add methods with yield for `scope`,`nodes`, `parents`, `children`, `left_iterator`, `right_iterator` methods

## 3.4.1
* Node#css change usage with block given, now it iterate all nodes `doc.css { |node| ... }`

## 3.4.0
* update liblexbor with css selector fix for :has, #48

## 3.3.2
* update liblexbor to latest
* add usage `Lexbor.new` instead of `Lexbor::Parser.new`

## 3.2.0
* update liblexbor to latest

## 3.1.3
* fix usage in interpreter

## 3.1.2
* add windows ci (thanks @etra0)

## 3.1.1
* fix windows build

## 3.1.0
* remove Makefile dependency
* add windows support
* update liblexbor

## 3.0.3
* fix processing svg in tokenizer

## 3.0.2
* add node attribute aliases, [], []?, fetch, has_key?

## 3.0.1
* update liblexbor, to fix remove single node attribute, #12

## 3.0.0
* update to latest liblexbor
* added css selectors
* added benchmarks
* temporary remove `Lexbor.decode_html_entities`

## 2.6.10
* fix maxOS build

## 2.6.9
* fix build on old cmake

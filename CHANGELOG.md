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

module Lexbor
  VERSION = "2.6.1"

  def self.lib_version
  end

  def self.version
    "Lexbor v#{VERSION} (liblexbor v1.0.0 3cf192ff8106a78a942bc0ad8b4d5e9e30a4c0b3)" # git describe --tags
  end

  #
  # Decode html entities
  #   Lexbor.decode_html_entities("&#61 &amp; &Auml") # => "= & Ä"
  #
  def self.decode_html_entities(str)
    Utils::HtmlEntities.decode(str)
  end
end

require "./lexbor/lib"
require "./lexbor/*"

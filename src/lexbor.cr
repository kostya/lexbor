module Lexbor
  VERSION = "2.2.0"

  def self.lib_version
  end

  def self.version
    "Lexbor v#{VERSION} (liblexbor v0.4.0-12-gb6c9c73)" # git describe --tags
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

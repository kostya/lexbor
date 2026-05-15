module Lexbor
  VERSION = "3.6.4"

  def self.lib_version
    "liblexbor v3.0.0"
  end

  def self.version
    "Lexbor v#{VERSION} (#{lib_version})"
  end

  # alias for parse document
  def self.new(v)
    Parser.new(v)
  end

  # Decode html entities
  #   Lexbor.decode_html_entities("&#61 &amp; &Auml") # => "= & Ä"
  # def self.decode_html_entities(str)
  #   Lexbor::Utils::HtmlEntities.decode(str)
  # end
end

require "./lexbor/lib"
require "./lexbor/*"

module Lexbor
  VERSION = "3.2.0"

  def self.lib_version
    "liblexbor v2.4.0 #{File.read(Path[__FILE__].parent / "ext" / "revision")}"
  end

  def self.version
    "Lexbor v#{VERSION} (#{lib_version})"
  end

  # Decode html entities
  #   Lexbor.decode_html_entities("&#61 &amp; &Auml") # => "= & Ä"
  # def self.decode_html_entities(str)
  #   Lexbor::Utils::HtmlEntities.decode(str)
  # end
end

require "./lexbor/lib"
require "./lexbor/*"

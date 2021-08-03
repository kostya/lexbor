module Lexbor
  lib Lib
    type CssParserT = Void*
    type SelectorsT = Void*
    type CssSelectorsT = Void*
    type CssSelectorsListT = Void*
    alias SelectorsCbF = DomElementT, Void*, Void* -> StatusT

    fun css_parser_create = lxb_css_parser_create : CssParserT
    fun css_parser_destroy = lxb_css_parser_destroy(parser : CssParserT, self_destroy : Bool) : CssParserT
    fun css_parser_init = lxb_css_parser_init(parser : CssParserT, tkz : Void*, mraw : Void*) : StatusT
    fun css_parser_selectors_set = lxb_css_parser_selectors_set(parser : CssParserT, selectors : CssSelectorsT)

    fun css_selectors_create = lxb_css_selectors_create : CssSelectorsT
    fun css_selectors_init = lxb_css_selectors_init(selectors : CssSelectorsT, prepare_count : LibC::SizeT) : StatusT
    fun css_selectors_parse = lxb_css_selectors_parse(parser : CssParserT, data : UInt8*, length : LibC::SizeT) : CssSelectorsListT
    fun css_selectors_destroy = lxb_css_selectors_destroy(selectors : CssSelectorsT, with_memory : Bool, self_destroy : Bool) : CssSelectorsT

    fun selectors_create = lxb_selectors_create : SelectorsT
    fun selectors_init = lxb_selectors_init(selectors : SelectorsT) : StatusT
    fun selectors_find = lxb_selectors_find(selectors : SelectorsT, root : DomElementT, list : CssSelectorsListT, cb : SelectorsCbF, ctx : Void*) : StatusT
    fun selectors_destroy = lxb_selectors_destroy(selectors : SelectorsT, self_destroy : Bool) : SelectorsT
    fun css_selector_list_destroy_memory = lxb_css_selector_list_destroy_memory(list : CssSelectorsListT)
  end
end

require "./lib/constants"

module Lexbor
  {% if flag?(:win32) %}
    @[Link(ldflags: "#{__DIR__}/../ext/lexbor-c/build/lexbor_static.lib")]
  {% elsif flag?(:interpreted) %}
    @[Link("lexbor", ldflags: "-L#{__DIR__}/../ext/lexbor-c/build/")]
  {% else %}
    @[Link(ldflags: "#{__DIR__}/../ext/lexbor-c/build/liblexbor_static.a")]
  {% end %}

  lib Lib
    type DocT = Void*
    type CollectionT = Void*
    type DomElementT = Void*
    type DomAttrT = Void*

    # Document
    fun document_create = lxb_html_document_create : DocT
    fun document_parse = lxb_html_document_parse(doc : DocT, html : UInt8*, len : LibC::SizeT) : StatusT
    fun document_destroy = lxb_html_document_destroy(doc : DocT)
    fun document_parse_chunk_begin = lxb_html_document_parse_chunk_begin(doc : DocT) : StatusT
    fun document_parse_chunk = lxb_html_document_parse_chunk(doc : DocT, html : UInt8*, size : LibC::SizeT) : StatusT
    fun document_parse_chunk_end = lxb_html_document_parse_chunk_end(doc : DocT) : StatusT
    fun html_element_inner_html_set = lxb_html_element_inner_html_set(node : DomElementT, html : UInt8*, size : LibC::SizeT) : DomElementT

    # Root nodes
    fun tree_get_node_head = lxb_html_document_head_element_noi(doc : DocT) : DomElementT
    fun tree_get_node_body = lxb_html_document_body_element_noi(doc : DocT) : DomElementT
    fun document_element = lxb_dom_document_element_noi(doc : DocT) : DomElementT

    # Collections
    fun collection_make = lxb_dom_collection_make_noi(doc : DocT, start_list_size : LibC::SizeT) : CollectionT
    fun collection_element = lxb_dom_collection_element_noi(col : CollectionT, idx : LibC::SizeT) : DomElementT
    fun collection_length = lxb_dom_collection_length_noi(col : CollectionT) : LibC::SizeT
    fun collection_destroy = lxb_dom_collection_destroy(col : CollectionT, self_destroy : Bool) : CollectionT
    fun collection_append = lxb_dom_collection_append_noi(col : CollectionT, value : Void*) : StatusT

    # Element info methods
    fun element_get_tag_id = lxb_dom_node_tag_id_noi(element : DomElementT) : Lexbor::Lib::TagIdT
    fun element_text_content = lxb_dom_node_text_content(element : DomElementT, len : LibC::SizeT*) : UInt8*
    fun element_text_content_set = lxb_dom_node_text_content_set(element : DomElementT, content : UInt8*, len : LibC::SizeT) : StatusT
    fun element_qualified_name = lxb_dom_element_qualified_name(element : DomElementT, len : LibC::SizeT*) : UInt8*
    fun element_local_name = lxb_dom_element_local_name_noi(element : DomElementT, len : LibC::SizeT*) : UInt8*
    fun node_is_void = lxb_html_node_is_void_noi(element : DomElementT) : Bool

    # Navigation methods
    fun element_get_next = lxb_dom_node_next_noi(element : DomElementT) : DomElementT
    fun element_get_prev = lxb_dom_node_prev_noi(element : DomElementT) : DomElementT
    fun element_get_parent = lxb_dom_node_parent_noi(element : DomElementT) : DomElementT
    fun element_get_child = lxb_dom_node_first_child_noi(element : DomElementT) : DomElementT
    fun element_get_last_child = lxb_dom_node_last_child_noi(element : DomElementT) : DomElementT

    # Attribute methods
    fun element_first_attribute = lxb_dom_element_first_attribute_noi(element : DomElementT) : DomAttrT
    fun element_next_attribute = lxb_dom_element_next_attribute_noi(attr : DomAttrT) : DomAttrT
    fun attribute_value = lxb_dom_attr_value_noi(attr : DomAttrT, length : LibC::SizeT*) : UInt8*
    fun attribute_local_name = lxb_dom_attr_local_name_noi(attr : DomAttrT, length : LibC::SizeT*) : UInt8*
    fun attribute_qualified_name = lxb_dom_attr_qualified_name_noi(attr : DomAttrT, length : LibC::SizeT*) : UInt8*
    fun attribute_remove = lxb_dom_element_remove_attribute(element : DomElementT, name : UInt8*, len : LibC::SizeT) : StatusT
    fun element_set_attribute = lxb_dom_element_set_attribute(element : DomElementT, qualified_name : UInt8*, qn_len : LibC::SizeT, value : UInt8*, value_len : LibC::SizeT) : DomAttrT

    # Serialize
    alias SerializeCbT = (UInt8*, LibC::SizeT, Void*) -> StatusT
    fun serialize_cb = lxb_html_serialize_cb(element : DomElementT, cb : SerializeCbT, ctx : Void*) : StatusT
    fun serialize_tree_cb = lxb_html_serialize_tree_cb(element : DomElementT, cb : SerializeCbT, ctx : Void*) : StatusT
    fun serialize_pretty_cb = lxb_html_serialize_pretty_cb(element : DomElementT, opt : SerializeOptT, ident : LibC::SizeT, cb : SerializeCbT, ctx : Void*) : StatusT
    fun serialize_pretty_tree_cb = lxb_html_serialize_pretty_tree_cb(element : DomElementT, opt : SerializeOptT, ident : LibC::SizeT, cb : SerializeCbT, ctx : Void*) : StatusT

    # Tree manipulation
    fun insert_child = lxb_dom_node_insert_child(to : DomElementT, element : DomElementT)
    fun insert_before = lxb_dom_node_insert_before(to : DomElementT, element : DomElementT)
    fun insert_after = lxb_dom_node_insert_after(to : DomElementT, element : DomElementT)
    fun node_remove = lxb_dom_node_remove(element : DomElementT)
    fun create_element = lxb_dom_document_create_element(doc : DocT, local_name : UInt8*, lname_len : LibC::SizeT, opt : Void*) : DomElementT
    fun create_text_element = lxb_dom_document_create_text_node(doc : DocT, data : UInt8*, len : LibC::SizeT) : DomElementT

    # Iterators
    fun simple_walk = lxb_dom_node_simple_walk(from : DomElementT, cb : Void*, ctx : Void*)
    # fun elements_by_tag_name = lxb_dom_elements_by_tag_name(root : DomElementT, col : CollectionT, qualified_name : UInt8*, len : LibC::SizeT) : StatusT

    # Tokenizer
    type HtmlTokenizerT = Void*
    type MRawT = Void*

    struct Str
      data : UInt8*
      length : LibC::SizeT
    end

    alias StrT = Str*
    type HashT = Void*

    struct TokenAttr
      name_begin : UInt8*
      name_end : UInt8*
      value_begin : UInt8*
      value_end : UInt8*
      name : DomAttrT
      value : UInt8*
      value_size : LibC::SizeT
      next : TokenAttrT
      prev : TokenAttrT
      type : HtmlTokenAttrTypeT
    end

    alias TokenAttrT = TokenAttr*

    struct HtmlToken
      begin_ : UInt8*
      end_ : UInt8*
      text_start : UInt8*
      text_end : UInt8*
      attr_first : TokenAttrT
      attr_last : TokenAttrT
      base_element : Void*
      null_count : LibC::SizeT
      tag_id : TagIdT
      type_ : HtmlTokenTypeT
    end

    alias HtmlTokenT = HtmlToken*
    alias HtmlTokenizerTokenF = HtmlTokenizerT, HtmlTokenT, Void* -> HtmlTokenT

    fun html_tokenizer_create = lxb_html_tokenizer_create : HtmlTokenizerT
    fun html_tokenizer_init = lxb_html_tokenizer_init(tkz : HtmlTokenizerT) : StatusT
    fun html_tokenizer_callback_token_done_set = lxb_html_tokenizer_callback_token_done_set_noi(tkx : HtmlTokenizerT, cb : HtmlTokenizerTokenF, ctx : Void*)
    fun html_tokenizer_begin = lxb_html_tokenizer_begin(tkz : HtmlTokenizerT) : StatusT
    fun html_tokenizer_chunk = lxb_html_tokenizer_chunk(tkz : HtmlTokenizerT, data : UInt8*, size : LibC::SizeT) : StatusT
    fun html_tokenizer_end = lxb_html_tokenizer_end(tkz : HtmlTokenizerT) : StatusT
    fun html_tokenizer_destroy = lxb_html_tokenizer_destroy(tkz : HtmlTokenizerT) : HtmlTokenizerT
    fun tag_name_by_id = lxb_tag_name_by_id_noi(hash : HashT, tag_id : TagIdT, len : LibC::SizeT*) : UInt8*
    fun html_tokenizer_tags_make = lxb_html_tokenizer_tags_make(tkz : HtmlTokenizerT, table_size : LibC::SizeT) : StatusT
    fun html_tokenizer_tags_destroy = lxb_html_tokenizer_tags_destroy(tkz : HtmlTokenizerT)
    fun html_tokenizer_status_set = lxb_html_tokenizer_status_set_noi(tkz : HtmlTokenizerT, status : StatusT)
    fun html_tokenizer_set_state_by_tag = lxb_html_tokenizer_set_state_by_tag(tkz : HtmlTokenizerT, scripting : Bool, tag_id : TagIdT, ns : NsIdT)
    fun html_token_attr_name = lxb_html_token_attr_name(attr : TokenAttrT, len : LibC::SizeT*) : UInt8*

    fun html_tokenizer_mraw = lxb_html_tokenizer_mraw_noi(tkz : HtmlTokenizerT) : MRawT
    fun html_tokenizer_tags = lxb_html_tokenizer_tags_noi(tkz : HtmlTokenizerT) : HashT
    fun str_destroy = lexbor_str_destroy(str : StrT, mraw : MRawT, obj : Bool) : StrT
    fun str_init = lexbor_str_init(str : StrT, mraw : MRawT, size : LibC::SizeT) : UInt8*
    fun mraw_create = lexbor_mraw_create : MRawT
    fun mraw_init = lexbor_mraw_init(mraw : MRawT, size : LibC::SizeT) : StatusT

    type HtmlTokenAttrTypeT = Int32
  end
end

require "./lib/*"

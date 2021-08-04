# Example: basic usage

require "../src/lexbor"

puts Lexbor.version

page = "<html><div class=aaa>bla</div></html>"
lexbor = Lexbor::Parser.new(page)

# html node
lexbor.root  # (.html) Lexbor::Node?
lexbor.root! # (.html!) Lexbor::Node

# body node
lexbor.body  # Lexbor::Node?
lexbor.body! # Lexbor::Node

# head node
lexbor.head  # Lexbor::Node?
lexbor.head! # Lexbor::Node

# iterator over all div nodes from root scope
# equal with lexbor.root!.scope.nodes(:div)
lexbor.nodes(Lexbor::Lib::TagIdT::LXB_TAG_DIV) # Iterator::Collection(Lexbor::Node)
lexbor.nodes(:div)                             # Iterator::Collection(Lexbor::Node)
lexbor.nodes("div")                            # Iterator::Collection(Lexbor::Node)

node = lexbor.nodes(:div).first # Lexbor::Node

# methods:
pp node.tag_id                # => LXB_TAG_DIV
pp node.tag_sym               # => :div
pp node.tag_name              # => "div"
pp node.is_tag_div?           # => true
pp node.attribute_by("class") # => "aaa"
pp node.attributes            # => {"class" => "aaa"}

pp node.to_html    # => "<div class=\"aaa\">bla</div>"
pp node.inner_text # => "bla"
pp node            # => Lexbor::Node(:div, {"class" => "aaa"})

# tree navigate methods (methods with !, returns not_nil! node):
node.child      # Lexbor::Node?, first child of node
node.next       # Lexbor::Node?, next node in the parent scope
node.parent     # Lexbor::Node?, parent node
node.prev       # Lexbor::Node?, previous node in the parent scope
node.left       # Lexbor::Node?, left node, in the html, from current
node.right      # Lexbor::Node?, right node, in the html, from current
node.flat_right # Lexbor::Node?, right node, in the html, from current, without node.children

# iterators:
node.children        # Iterator::Collection(Lexbor::Node), iterate over all direct node children
node.parents         # Iterator::Collection(Lexbor::Node), iterate over all node parents from current to root! node
node.scope           # Iterator::Collection(Lexbor::Node), iterate over all inner nodes (children and deeper)
node.right_iterator  # Iterator::Collection(Lexbor::Node), iterate from current node to right (to the end of document)
node.left_iterator   # Iterator::Collection(Lexbor::Node), iterate from current node to left (to the root! node)
node.scope.nodes(:a) # Iterator::Collection(Lexbor::Node), select :a nodes in scope of `node`

# free lexbor c object,
# not really needed to call manyally, because called auto from GC finalize, when object not used anymore
# use it only if need to free memory fast
# after free any other child object like Lexbor::Node or Iterator::Collection(Lexbor::Node) not valid anymore and can lead to segfault
lexbor.free

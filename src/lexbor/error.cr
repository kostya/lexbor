# Exception for errors raised by this shard.
class Lexbor::Error < Exception
end

# Raised when trying to enter not exist node
class Lexbor::EmptyNodeError < Lexbor::Error
end

# Raised when unexpected input
class Lexbor::ArgumentError < Lexbor::Error
end

# Raised when lexbor library return bad status
class Lexbor::LibError < Lexbor::Error
end

# Just a simple wrapper for RuntimeError so users will know where
# exceptions came from
module Payday
  class Error < Exception; end
end
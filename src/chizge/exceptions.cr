module Chizge::Exceptions
  class NodeNotFoundException < Exception
    def initialize(node)
      super "Requested node not found: '#{node}'"
    end
  end

  class EdgeNotFoundException < Exception
  end
end

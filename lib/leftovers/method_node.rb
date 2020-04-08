module Leftovers
  class MethodNode
    attr_reader :node

    def initialize(node)
      @node = node
    end

    def name
      @name ||= node.children[1].to_s.freeze
    end

    def kwargs
      return @kwargs if defined?(@kwargs)

      @kwargs = HashNode.try(arguments[-1])
    end

    def loc
      @loc ||= node.loc
    end

    def arguments
      @arguments ||= node.children.drop(2)
    end
  end
end

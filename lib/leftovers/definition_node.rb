# frozen-string-literal: true

module Leftovers
  class DefinitionNode
    attr_reader :name, :loc, :node

    def initialize(node, name:, location: node.loc.expression)
      @node = node
      @name = name
      @loc = location
    end

    def kwargs
      nil
    end

    def positional_arguments
      nil
    end

    def path
      node.path
    end
  end
end

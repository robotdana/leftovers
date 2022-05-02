# frozen-string-literal: true

module Leftovers
  class DefinitionNode < ::Leftovers::AST::Node
    attr_reader :name, :path
    alias_method :to_sym, :name

    def initialize(node, name:, location: node.loc.expression)
      @name = name
      @path = node.path
      @location = location
      super(:leftovers_definition)
    end

    def to_s
      name.to_s
    end
  end
end

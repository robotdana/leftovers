# frozen-string-literal: true

module Leftovers
  class DefinitionNodeSet
    attr_reader :definitions

    def initialize
      @definitions = []
    end

    def add_definition_node(definition_node)
      @definitions << definition_node
    end

    def add_definition_set(definition_node_set)
      @definitions.concat(definition_node_set.definitions)
    end
  end
end

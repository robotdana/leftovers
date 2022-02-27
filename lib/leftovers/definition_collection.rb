# frozen_string_literal: true

module Leftovers
  class DefinitionCollection
    def initialize
      @definitions_to_add = {}
      @definition_sets_to_add = []
    end

    def add_definition_node(definition_node)
      add(definition_node, loc: definition_node.loc)
    end

    def add(node, name: node.name, loc: node.loc.name)
      @definitions_to_add[name] = ::Leftovers::DefinitionToAdd.new(node, name: name, location: loc)
    end

    def add_definition_set(definition_node_set)
      @definition_sets_to_add << definition_node_set.definitions.map do |definition_node|
        ::Leftovers::DefinitionToAdd.new(definition_node, location: definition_node.loc)
      end
    end

    def set_privacy(name, to)
      @definitions_to_add[name]&.privacy = to
    end

    def to_definitions(file_collector)
      @definitions_to_add.each_value.map { |d| d.to_definition(file_collector) } +
        @definition_sets_to_add.map do |definition_set|
          next if definition_set.any? { |d| d.keep?(file_collector) }

          ::Leftovers::DefinitionSet.new(definition_set.map { |d| d.to_definition(file_collector) })
        end
    end
  end
end

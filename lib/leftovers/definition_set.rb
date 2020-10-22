# frozen_string_literal: true

require_relative 'definition'

module Leftovers
  class DefinitionSet < Leftovers::Definition
    attr_reader :definitions

    def initialize(
      definitions,
      method_node: nil,
      location: method_node.loc.expression,
      test: method_node.test?
    )
      @definitions = definitions

      super
    end

    def names
      @definitions.map(&:names)
    end

    def to_s
      @definitions.map(&:to_s).join(', ')
    end

    def in_collection?
      @definitions.any?(&:in_collection?)
    end

    def in_test_collection?
      @definitions.any?(&:in_test_collection?)
    end
  end
end

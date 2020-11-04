# frozen_string_literal: true

module Leftovers
  class DefinitionSet
    attr_reader :definitions

    def initialize(definitions)
      @definitions = definitions

      freeze
    end

    def names
      @definitions.map(&:names)
    end

    def to_s
      @definitions.map(&:to_s).join(', ')
    end

    def location_s
      @definitions.first.location_s
    end

    def highlighted_source(*args)
      @definitions.first.highlighted_source(*args)
    end

    def in_collection?
      @definitions.any?(&:in_collection?)
    end

    def test?
      @definitions.any?(&:test?)
    end

    def in_test_collection?
      @definitions.any?(&:in_test_collection?)
    end
  end
end

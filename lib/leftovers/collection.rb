# frozen_string_literal: true

require 'set'

module Leftovers
  class Collection
    attr_reader :calls, :test_calls, :definitions

    def initialize
      @calls = []
      @test_calls = []
      @definitions = []
    end

    def leftovers
      @leftovers ||= begin
        freeze_calls

        @definitions
          .reject { |definition| definition.in_collection?(self) }
          .sort_by(&:location_s).freeze
      end
    end

    def with_tests
      split_leftovers.first
    end

    def without_tests
      split_leftovers[1]
    end

    def empty?
      leftovers.empty?
    end

    def concat(calls:, definitions:, test:)
      if test
        @test_calls.concat(calls)
      else
        @calls.concat(calls)
      end

      @definitions.concat(definitions)
    end

    private

    def split_leftovers
      return @split_leftovers if defined?(@split_leftovers)

      @split_leftovers = leftovers.partition do |definition|
        !definition.test? && definition.in_test_collection?(self)
      end.each(&:freeze).freeze

      freeze

      @split_leftovers
    end

    def freeze_calls
      @calls = @calls.to_set.freeze
      @test_calls = @test_calls.to_set.freeze
    end
  end
end

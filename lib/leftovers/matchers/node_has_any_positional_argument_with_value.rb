# frozen_string_literal: true

module Leftovers
  module Matchers
    class NodeHasAnyPositionalArgumentWithValue
      def initialize(matcher)
        @matcher = matcher

        freeze
      end

      def ===(node)
        node.positional_arguments.any? do |value|
          @matcher === value
        end
      end

      freeze
    end
  end
end

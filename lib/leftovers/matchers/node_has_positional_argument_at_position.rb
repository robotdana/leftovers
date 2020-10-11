# frozen_string_literal: true

module Leftovers
  module Matchers
    class NodeHasPositionalArgumentAtPosition
      def initialize(position, matcher)
        @position = position
        @matcher = matcher

        freeze
      end

      def ===(node)
        @matcher === node.positional_arguments[position]
      end

      freeze
    end
  end
end

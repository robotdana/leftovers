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
        value_node = node.positional_arguments[@position]
        @matcher === value_node if value_node
      end

      freeze
    end
  end
end

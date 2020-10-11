# frozen_string_literal: true

module Leftovers
  module Matchers
    class NodeHasPositionalArgumentLengthMinimum
      def initialize(length_minimum)
        @length_minimum = length_minimum

        freeze
      end

      def ===(node)
        @length_minimum <= node.positional_arguments.length
      end

      freeze
    end
  end
end

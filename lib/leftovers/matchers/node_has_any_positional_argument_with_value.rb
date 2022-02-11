# frozen_string_literal: true

module Leftovers
  module Matchers
    class NodeHasAnyPositionalArgumentWithValue
      def initialize(matcher)
        @matcher = matcher

        freeze
      end

      def ===(node)
        args = node.positional_arguments
        return false unless args

        args.any?(@matcher)
      end

      freeze
    end
  end
end

# frozen_string_literal: true

module Leftovers
  module Matchers
    class NodeHasAnyPositionalArgumentWithValue
      attr_reader :matcher

      def initialize(matcher)
        @matcher = matcher

        freeze
      end

      def ===(node)
        node.positional_arguments&.any?(@matcher)
      end

      freeze
    end
  end
end

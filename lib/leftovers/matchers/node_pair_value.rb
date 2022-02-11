# frozen_string_literal: true

module Leftovers
  module Matchers
    class NodePairValue
      def initialize(value_matcher)
        @value_matcher = value_matcher

        freeze
      end

      def ===(node)
        @value_matcher === node.second
      end

      freeze
    end
  end
end

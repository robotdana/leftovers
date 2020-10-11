# frozen_string_literal: true

module Leftovers
  module Matchers
    class NodeHasKeywordArgument
      def initialize(pair_matcher)
        @pair_matcher = pair_matcher

        freeze
      end

      def ===(node)
        node.kwargs&.children&.any? do |pair|
          @pair_matcher === pair
        end
      end

      freeze
    end
  end
end

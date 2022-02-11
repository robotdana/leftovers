# frozen_string_literal: true

module Leftovers
  module Matchers
    class NodeHasAnyKeywordArgument
      def initialize(pair_matcher)
        @pair_matcher = pair_matcher

        freeze
      end

      def ===(node)
        kwargs = node.kwargs
        return false unless kwargs

        kwargs.children.any?(@pair_matcher)
      end

      freeze
    end
  end
end

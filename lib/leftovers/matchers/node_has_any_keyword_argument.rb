# frozen_string_literal: true

module Leftovers
  module Matchers
    class NodeHasAnyKeywordArgument
      attr_reader :matcher

      def initialize(matcher)
        @matcher = matcher

        freeze
      end

      def ===(node)
        kwargs = node.kwargs
        return false unless kwargs

        kwargs.children.any?(@matcher)
      end

      freeze
    end
  end
end

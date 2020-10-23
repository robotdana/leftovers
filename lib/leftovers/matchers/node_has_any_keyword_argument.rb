# frozen_string_literal: true

module Leftovers
  module Matchers
    class NodeHasAnyKeywordArgument
      # :nocov:
      using ::Leftovers::Backports::SetCaseEq if defined?(::Leftovers::Backports::SetCaseEq)
      # :nocov:

      def initialize(pair_matcher)
        @pair_matcher = pair_matcher

        freeze
      end

      def ===(node)
        kwargs = node.kwargs
        return false unless kwargs

        kwargs.children.any? do |pair|
          @pair_matcher === pair
        end
      end

      freeze
    end
  end
end

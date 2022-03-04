# frozen_string_literal: true

module Leftovers
  module Matchers
    class NodeHasAnyKeywordArgument
      include ComparableInstance

      attr_reader :matcher

      def initialize(matcher)
        @matcher = matcher

        freeze
      end

      def ===(node)
        kwargs = node.kwargs

        kwargs.children.any?(@matcher) if kwargs # rubocop:disable Style/SafeNavigation because there are multiple steps and this should be a configuration option
      end

      freeze
    end
  end
end

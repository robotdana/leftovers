# frozen_string_literal: true

module Leftovers
  module Matchers
    class NodePairValue
      # :nocov:
      using ::Leftovers::SetCaseEq if defined?(::Leftovers::SetCaseEq)
      # :nocov:

      def initialize(value_matcher)
        @value_matcher = value_matcher

        freeze
      end

      def ===(node)
        @value_matcher === node.pair_value
      end

      freeze
    end
  end
end

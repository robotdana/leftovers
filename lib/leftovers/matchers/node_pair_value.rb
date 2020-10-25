# frozen_string_literal: true

module Leftovers
  module Matchers
    class NodePairValue
      # :nocov:
      using ::Leftovers::Backports::SetCaseEq if defined?(::Leftovers::Backports::SetCaseEq)
      # :nocov:

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

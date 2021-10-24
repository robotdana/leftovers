# frozen_string_literal: true

module Leftovers
  module Matchers
    class NodeHasAnyPositionalArgumentWithValue
      # :nocov:
      using ::Leftovers::Backports::SetCaseEq if defined?(::Leftovers::Backports::SetCaseEq)
      # :nocov:

      def initialize(matcher)
        @matcher = matcher

        freeze
      end

      def ===(node)
        args = node.positional_arguments
        return false unless args

        args.any? do |value|
          @matcher === value
        end
      end

      freeze
    end
  end
end

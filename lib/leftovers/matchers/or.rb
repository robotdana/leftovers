# frozen_string_literal: true

module Leftovers
  module Matchers
    class Or
      # :nocov:
      using ::Leftovers::SetCaseEq if defined?(::Leftovers::SetCaseEq)
      # :nocov:

      def initialize(lhs, rhs)
        @lhs = lhs
        @rhs = rhs

        freeze
      end

      # lets me use flatten
      def to_ary
        [@lhs, @rhs]
      end

      def ===(value)
        @lhs === value || @rhs === value
      end

      freeze
    end
  end
end

# frozen_string_literal: true

module Leftovers
  module Matchers
    class And
      # :nocov:
      using ::Leftovers::Backports::SetCaseEq if defined?(::Leftovers::Backports::SetCaseEq)
      # :nocov:

      def initialize(lhs, rhs)
        @lhs = lhs
        @rhs = rhs

        freeze
      end

      def ===(value)
        @lhs === value && @rhs === value
      end

      freeze
    end
  end
end

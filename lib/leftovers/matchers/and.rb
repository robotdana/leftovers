# frozen_string_literal: true

module Leftovers
  module Matchers
    class And
      include ComparableInstance

      attr_reader :lhs, :rhs

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

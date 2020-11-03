# frozen_string_literal: true

module Leftovers
  module Matchers
    class Any
      # :nocov:
      using ::Leftovers::Backports::SetCaseEq if defined?(::Leftovers::Backports::SetCaseEq)
      # :nocov:

      attr_reader :matchers

      def initialize(matchers)
        @matchers = matchers

        freeze
      end

      def ===(value)
        @matchers.any? do |matcher|
          matcher === value
        end
      end

      freeze
    end
  end
end

# frozen_string_literal: true

module Leftovers
  module Matchers
    class All
      # :nocov:
      using ::Leftovers::Backports::SetCaseEq if defined?(::Leftovers::Backports::SetCaseEq)
      # :nocov:

      def initialize(matchers)
        @matchers = matchers

        freeze
      end

      def ===(value)
        @matchers.all? do |matcher|
          matcher === value
        end
      end

      freeze
    end
  end
end

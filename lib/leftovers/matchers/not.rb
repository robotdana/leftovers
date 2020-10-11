# frozen_string_literal: true

module Leftovers
  module Matchers
    class Not
      # :nocov:
      using ::Leftovers::SetCaseEq if defined?(::Leftovers::SetCaseEq)
      # :nocov:

      def initialize(matcher)
        @matcher = matcher

        freeze
      end

      def ===(value)
        !(@matcher === value)
      end

      freeze
    end
  end
end

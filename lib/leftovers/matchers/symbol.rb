# frozen_string_literal: true

module Leftovers
  module Matchers
    class Symbol
      # :nocov:
      using ::Leftovers::SetCaseEq if defined?(::Leftovers::SetCaseEq)
      # :nocov:

      attr_reader :syms, :regexp

      def initialize(syms, regexp)
        @syms = syms
        @regexp = regexp

        freeze
      end

      def ===(sym)
        @syms === sym || @regexp === sym
      end
    end
  end
end

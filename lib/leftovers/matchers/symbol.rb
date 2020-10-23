# frozen_string_literal: true

module Leftovers
  module Matchers
    class Symbol
      # :nocov:
      using ::Leftovers::Backports::SetCaseEq if defined?(::Leftovers::Backports::SetCaseEq)
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

      freeze
    end
  end
end

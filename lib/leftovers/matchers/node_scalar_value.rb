# frozen-string-literal: true

module Leftovers
  module Matchers
    class NodeScalarValue
      # :nocov:
      using ::Leftovers::Backports::SetCaseEq if defined?(::Leftovers::Backports::SetCaseEq)
      # :nocov:

      def initialize(matcher)
        @matcher = matcher

        freeze
      end

      def ===(node)
        return false unless node.scalar?

        @matcher === node.to_scalar_value
      end

      freeze
    end
  end
end

# frozen-string-literal: true

module Leftovers
  module Matchers
    class NodeScalarValue
      attr_reader :matcher

      def initialize(matcher)
        @matcher = matcher

        freeze
      end

      def ===(node)
        # can't just check to_scalar_value, it might be false/nil on purpose.
        return unless node.scalar?

        @matcher === node.to_scalar_value
      end

      freeze
    end
  end
end

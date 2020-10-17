# frozen_string_literal: true

module Leftovers
  module Matchers
    class NodeHasPositionalArgument
      def initialize(position)
        @position = position

        freeze
      end

      def ===(node)
        node.positional_arguments[@position]
      end

      freeze
    end
  end
end

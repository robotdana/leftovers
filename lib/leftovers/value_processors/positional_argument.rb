# frozen_string_literal: true

module Leftovers
  module ValueProcessors
    class PositionalArgument
      def initialize(index, then_processor)
        @index = index
        @then_processor = then_processor

        freeze
      end

      def process(_str, node, method_node)
        positional_arguments = node.positional_arguments
        return unless positional_arguments

        argument_node = positional_arguments[@index]
        return unless argument_node

        str = argument_node.to_s if argument_node.string_or_symbol?

        @then_processor.process(str, argument_node, method_node)
      end
    end
  end
end

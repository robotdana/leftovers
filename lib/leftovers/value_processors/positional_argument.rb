# frozen_string_literal: true

module Leftovers
  module ValueProcessors
    class PositionalArgument
      def initialize(index, then_processor)
        @index = index
        @then_processor = then_processor

        freeze
      end

      def process(_str, node, method_node, acc)
        positional_arguments = node.positional_arguments
        return unless positional_arguments

        argument_node = positional_arguments[@index]
        return unless argument_node

        @then_processor.process(argument_node.to_repeatable_s, argument_node, method_node, acc)
      end

      freeze
    end
  end
end

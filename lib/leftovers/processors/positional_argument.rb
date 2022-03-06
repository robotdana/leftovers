# frozen_string_literal: true

module Leftovers
  module Processors
    class PositionalArgument
      include ComparableInstance

      def initialize(index, then_processor)
        @index = index
        @then_processor = then_processor

        freeze
      end

      def process(_str, current_node, matched_node, acc)
        positional_arguments = current_node.positional_arguments
        return unless positional_arguments

        argument_node = positional_arguments[@index]
        return unless argument_node

        @then_processor.process(argument_node.to_literal_s, argument_node, matched_node, acc)
      end

      freeze
    end
  end
end

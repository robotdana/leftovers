# frozen_string_literal: true

module Leftovers
  module Processors
    class EachPositionalArgumentFrom
      def initialize(position, then_processor)
        @position = position
        @then_processor = then_processor

        freeze
      end

      def process(_str, node, method_node, acc)
        positional_arguments = node.positional_arguments

        return unless positional_arguments

        positional_arguments.each_with_index do |argument_node, index|
          next if index < @position

          @then_processor.process(argument_node.to_repeatable_s, argument_node, method_node, acc)
        end
      end

      freeze
    end
  end
end

# frozen_string_literal: true

module Leftovers
  module ValueProcessors
    class EachPositionalArgument
      def initialize(then_processor)
        @then_processor = then_processor

        freeze
      end

      def process(_str, node, method_node, acc)
        positional_arguments = node.positional_arguments

        return unless positional_arguments

        positional_arguments.each do |argument_node|
          str = argument_node.to_s if argument_node.string_or_symbol_or_def?

          @then_processor.process(str, argument_node, method_node, acc)
        end
      end

      freeze
    end
  end
end

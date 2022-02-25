# frozen_string_literal: true

module Leftovers
  module ValueProcessors
    class EachPositionalArgument
      def initialize(then_processor)
        @then_processor = then_processor

        freeze
      end

      def process(_str, node, method_node)
        positional_arguments = node.positional_arguments

        return unless positional_arguments

        Leftovers.map_or_self(positional_arguments) do |argument_node|
          str = argument_node.to_s if argument_node.string_or_symbol_or_def?

          @then_processor.process(str, argument_node, method_node)
        end
      end
    end
  end
end

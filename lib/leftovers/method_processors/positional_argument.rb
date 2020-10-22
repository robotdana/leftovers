# frozen_string_literal: true

module Leftovers
  module MethodProcessors
    class PositionalArgument
      def initialize(index, then_processor)
        @index = index
        @then_processor = then_processor
      end

      def process(method_node)
        sym_node = method_node.positional_arguments[@index]
        return unless sym_node&.string_or_symbol?

        @then_processor.process(sym_node.to_s, sym_node, method_node)
      end
    end
  end
end

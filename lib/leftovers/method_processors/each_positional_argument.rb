# frozen_string_literal: true

module Leftovers
  module MethodProcessors
    class EachPositionalArgument
      def initialize(then_processor)
        @then_processor = then_processor
      end

      def process(method_node)
        method_node.positional_arguments.map do |sym_node|
          next unless sym_node.string_or_symbol?

          @then_processor.process(sym_node.to_s, sym_node, method_node)
        end
      end
    end
  end
end

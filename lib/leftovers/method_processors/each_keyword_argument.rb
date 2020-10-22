# frozen_string_literal: true

module Leftovers
  module MethodProcessors
    class EachKeywordArgument
      def initialize(then_processor)
        @then_processor = then_processor
      end

      def process(method_node)
        kwargs = method_node.kwargs
        return unless kwargs

        method_node.kwargs.children.map do |pair|
          sym_node = pair.second
          next unless sym_node.string_or_symbol?

          @then_processor.process(sym_node.to_s, sym_node, method_node)
        end
      end
    end
  end
end

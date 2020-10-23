# frozen_string_literal: true

module Leftovers
  module ValueProcessors
    class EachKeywordArgument
      def initialize(then_processor)
        @then_processor = then_processor
      end

      def process(_str, node, method_node)
        kwargs = node.kwargs
        return unless kwargs

        method_node.kwargs.children.map do |pair|
          argument_node = pair.second
          str = argument_node.to_s if argument_node.string_or_symbol?

          @then_processor.process(str, argument_node, method_node)
        end
      end
    end
  end
end

# frozen_string_literal: true

module Leftovers
  module ValueProcessors
    class EachKeyword
      def initialize(then_processor)
        @then_processor = then_processor

        freeze
      end

      def process(_str, node, method_node)
        kwargs = node.kwargs
        return unless kwargs

        kwargs.children.map do |pair|
          argument_node = pair.first
          str = argument_node.to_s if argument_node.string_or_symbol?

          @then_processor.process(str, argument_node, method_node)
        end
      end
    end
  end
end

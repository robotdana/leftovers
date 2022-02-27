# frozen_string_literal: true

module Leftovers
  module ValueProcessors
    class EachKeywordArgument
      def initialize(then_processor)
        @then_processor = then_processor

        freeze
      end

      def process(_str, node, method_node)
        kwargs = node.kwargs
        return unless kwargs

        Leftovers.map_or_self(kwargs.children) do |pair|
          next unless pair.type == :pair

          argument_node = pair.second
          str = argument_node.to_s if argument_node.string_or_symbol?

          @then_processor.process(str, argument_node, method_node)
        end
      end

      freeze
    end
  end
end

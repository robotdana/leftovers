# frozen_string_literal: true

module Leftovers
  module Processors
    class EachKeywordArgument
      def initialize(then_processor)
        @then_processor = then_processor

        freeze
      end

      def process(_str, node, method_node, acc)
        kwargs = node.kwargs
        return unless kwargs

        kwargs.children.each do |pair|
          next unless pair.type == :pair

          value_node = pair.second
          @then_processor.process(value_node.to_repeatable_s, value_node, method_node, acc)
        end
      end

      freeze
    end
  end
end

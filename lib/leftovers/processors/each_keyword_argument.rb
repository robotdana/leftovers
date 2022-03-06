# frozen_string_literal: true

module Leftovers
  module Processors
    class EachKeywordArgument
      include ComparableInstance

      def initialize(then_processor)
        @then_processor = then_processor

        freeze
      end

      def process(_str, current_node, matched_node, acc)
        kwargs = current_node.kwargs
        return unless kwargs

        kwargs.children.each do |pair|
          next unless pair.type == :pair

          value_node = pair.second
          @then_processor.process(value_node.to_literal_s, value_node, matched_node, acc)
        end
      end

      freeze
    end
  end
end

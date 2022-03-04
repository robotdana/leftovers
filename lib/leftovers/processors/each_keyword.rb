# frozen_string_literal: true

module Leftovers
  module Processors
    class EachKeyword
      include ComparableInstance

      def initialize(then_processor)
        @then_processor = then_processor

        freeze
      end

      def process(_str, node, method_node, acc)
        kwargs = node.kwargs
        return unless kwargs

        kwargs.children.each do |pair|
          next unless pair.type == :pair

          key_node = pair.first
          @then_processor.process(key_node.to_repeatable_s, key_node, method_node, acc)
        end
      end

      freeze
    end
  end
end

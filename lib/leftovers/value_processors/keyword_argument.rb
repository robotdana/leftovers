# frozen_string_literal: true

module Leftovers
  module ValueProcessors
    class KeywordArgument
      def initialize(matcher, then_processor)
        @matcher = matcher
        @then_processor = then_processor

        freeze
      end

      def process(_str, node, method_node, acc)
        kwargs = node.kwargs
        return unless kwargs

        kwargs.children.each do |pair|
          next unless @matcher === pair

          argument_node = pair.second
          str = argument_node.to_s if argument_node.string_or_symbol?

          @then_processor.process(str, argument_node, method_node, acc)
        end
      end

      freeze
    end
  end
end

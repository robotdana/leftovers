# frozen_string_literal: true

module Leftovers
  module MethodProcessors
    class KeywordArgument
      def initialize(matcher, then_processor)
        @matcher = matcher
        @then_processor = then_processor
      end

      def process(_str, node, method_node)
        kwargs = node.kwargs
        return unless kwargs

        result = []

        kwargs.children.each do |pair|
          next unless @matcher === pair

          argument_node = pair.pair_value
          str = argument_node.to_s if argument_node.string_or_symbol?

          result << @then_processor.process(str, argument_node, method_node)
        end

        result
      end
    end
  end
end

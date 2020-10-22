# frozen_string_literal: true

module Leftovers
  module MethodProcessors
    class KeywordArgument
      def initialize(matcher, then_processor)
        @matcher = matcher
        @then_processor = then_processor
      end

      def process(method_node)
        kwargs = method_node.kwargs
        return unless kwargs

        result = []

        kwargs.children.each do |pair|
          next unless @matcher === pair

          sym_node = pair.pair_value
          next unless sym_node.string_or_symbol?

          result << @then_processor.process(sym_node.to_s, sym_node, method_node)
        end

        result
      end
    end
  end
end

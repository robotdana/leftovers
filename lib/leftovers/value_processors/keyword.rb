# frozen_string_literal: true

module Leftovers
  module ValueProcessors
    class Keyword
      def initialize(matcher, then_processor)
        @matcher = matcher
        @then_processor = then_processor

        freeze
      end

      def process(_str, node, method_node)
        kwargs = node.kwargs
        return unless kwargs

        result = []

        kwargs.children.each do |pair|
          next unless @matcher === pair

          argument_node = pair.first
          str = argument_node.to_s

          result << @then_processor.process(str, argument_node, method_node)
        end

        result
      end
    end
  end
end

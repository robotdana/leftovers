# frozen_string_literal: true

module Leftovers
  module Processors
    class AddPrefix
      def initialize(prefix, then_processor)
        @prefix = prefix
        @then_processor = then_processor

        freeze
      end

      def process(str, node, method_node, acc)
        return unless str

        @then_processor.process("#{@prefix}#{str}", node, method_node, acc)
      end

      freeze
    end
  end
end

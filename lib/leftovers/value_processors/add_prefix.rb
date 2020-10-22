# frozen_string_literal: true

module Leftovers
  module ValueProcessors
    class AddPrefix
      def initialize(prefix, then_processor)
        @prefix = prefix
        @then_processor = then_processor
      end

      def process(str, node, method_node)
        @then_processor.process("#{@prefix}#{str}", node, method_node)
      end
    end
  end
end

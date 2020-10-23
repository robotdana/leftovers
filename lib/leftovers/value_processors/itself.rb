# frozen_string_literal: true

module Leftovers
  module ValueProcessors
    class Itself
      def initialize(then_processor)
        @then_processor = then_processor
      end

      def process(_str, node, method_node)
        @then_processor.process(method_node.to_s, node, method_node)
      end
    end
  end
end

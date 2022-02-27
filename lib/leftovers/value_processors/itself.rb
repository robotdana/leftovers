# frozen_string_literal: true

module Leftovers
  module ValueProcessors
    class Itself
      def initialize(then_processor)
        @then_processor = then_processor

        freeze
      end

      def process(_str, node, method_node, acc)
        @then_processor.process(method_node.to_s, node, method_node, acc)
      end

      freeze
    end
  end
end

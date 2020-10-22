# frozen_string_literal: true

module Leftovers
  module ValueProcessors
    class Singularize
      def initialize(then_processor)
        @then_processor = then_processor
      end

      def process(str, node, method_node)
        @then_processor.process(str.singularize, node, method_node)
      end
    end
  end
end

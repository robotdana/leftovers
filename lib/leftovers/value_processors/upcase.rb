# frozen_string_literal: true

module Leftovers
  module ValueProcessors
    class Upcase
      def initialize(then_processor)
        @then_processor = then_processor
      end

      def process(str, node, method_node)
        @then_processor.process(str.upcase, node, method_node)
      end
    end
  end
end
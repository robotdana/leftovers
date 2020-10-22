# frozen_string_literal: true

module Leftovers
  module ValueProcessors
    class Downcase
      def initialize(then_processor)
        @then_processor = then_processor
      end

      def process(str, node, method_node)
        @then_processor.process(str.downcase, node, method_node)
      end
    end
  end
end

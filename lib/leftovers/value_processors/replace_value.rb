# frozen_string_literal: true

module Leftovers
  module ValueProcessors
    class ReplaceValue
      def initialize(value, then_processor)
        @value = value
        @then_processor = then_processor
      end

      def process(_str, node, method_node)
        @then_processor.process(@value, node, method_node)
      end
    end
  end
end

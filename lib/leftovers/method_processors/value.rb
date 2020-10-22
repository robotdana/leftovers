# frozen_string_literal: true

module Leftovers
  module MethodProcessors
    class Value
      def initialize(value, then_processor)
        @value = value
        @then_processor = then_processor
      end

      def process(method_node)
        @then_processor.process(@value, method_node, method_node)
      end
    end
  end
end

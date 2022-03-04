# frozen_string_literal: true

module Leftovers
  module Processors
    class ReplaceValue
      include ComparableInstance

      def initialize(value, then_processor)
        @value = value
        @then_processor = then_processor

        freeze
      end

      def process(_str, node, method_node, acc)
        @then_processor.process(@value, node, method_node, acc)
      end

      freeze
    end
  end
end

# frozen_string_literal: true

module Leftovers
  module Processors
    class Itself
      include ComparableInstance

      def initialize(then_processor)
        @then_processor = then_processor

        freeze
      end

      def process(_str, current_node, matched_node, acc)
        @then_processor.process(current_node.to_s, current_node, matched_node, acc)
      end

      freeze
    end
  end
end

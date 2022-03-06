# frozen_string_literal: true

module Leftovers
  module Processors
    class Receiver
      include ComparableInstance

      def initialize(then_processor)
        @then_processor = then_processor

        freeze
      end

      def process(_str, current_node, matched_node, acc)
        receiver = matched_node.receiver
        return unless receiver

        @then_processor.process(receiver.to_s, current_node, matched_node, acc)
      end

      freeze
    end
  end
end

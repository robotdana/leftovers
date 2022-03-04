# frozen_string_literal: true

module Leftovers
  module Processors
    class Receiver
      include ComparableInstance

      def initialize(then_processor)
        @then_processor = then_processor

        freeze
      end

      def process(_str, node, method_node, acc)
        receiver = method_node.receiver
        return unless receiver

        @then_processor.process(receiver.to_s, node, method_node, acc)
      end

      freeze
    end
  end
end

# frozen_string_literal: true

module Leftovers
  module ValueProcessors
    class DeleteBefore
      def initialize(delete_before, then_processor)
        @delete_before = delete_before
        @then_processor = then_processor

        freeze
      end

      def process(str, node, method_node, acc)
        return unless str

        # TODO: investigate index
        str = str.split(@delete_before, 2)[1] || str
        @then_processor.process(str, node, method_node, acc)
      end

      freeze
    end
  end
end

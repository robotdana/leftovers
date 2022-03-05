# frozen_string_literal: true

module Leftovers
  module Processors
    class DeleteBefore
      include ComparableInstance

      def initialize(delete_before, then_processor)
        @delete_before = delete_before
        @delete_before_length = delete_before.length
        @then_processor = then_processor

        freeze
      end

      def process(str, node, method_node, acc)
        return unless str

        index = str.index(@delete_before)
        str = str[(index + @delete_before_length)..-1] if index
        @then_processor.process(str, node, method_node, acc)
      end

      freeze
    end
  end
end

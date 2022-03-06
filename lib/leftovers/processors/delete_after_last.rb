# frozen_string_literal: true

module Leftovers
  module Processors
    class DeleteAfterLast
      include ComparableInstance

      def initialize(delete_after, then_processor)
        @delete_after = delete_after
        @then_processor = then_processor

        freeze
      end

      def process(str, current_node, matched_node, acc)
        return unless str

        index = str.rindex(@delete_after)
        str = str[0...index] if index
        @then_processor.process(str, current_node, matched_node, acc)
      end

      freeze
    end
  end
end

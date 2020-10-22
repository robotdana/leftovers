# frozen_string_literal: true

module Leftovers
  module ValueProcessors
    class DeleteAfter
      def initialize(delete_after, then_processor)
        @delete_after = delete_after
        @then_processor = then_processor
      end

      def process(str, node, method_node)
        # TODO: investigate index
        str = str.split(@delete_after, 2).first || str
        @then_processor.process(str, node, method_node)
      end
    end
  end
end

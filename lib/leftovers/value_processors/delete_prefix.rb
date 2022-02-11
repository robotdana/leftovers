# frozen_string_literal: true

module Leftovers
  module ValueProcessors
    class DeletePrefix
      def initialize(prefix, then_processor)
        @prefix = prefix
        @then_processor = then_processor

        freeze
      end

      def process(str, node, method_node)
        return unless str

        @then_processor.process(str.delete_prefix(@prefix), node, method_node)
      end
    end
  end
end

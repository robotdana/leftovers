# frozen_string_literal: true

module Leftovers
  module ValueProcessors
    class DeleteSuffix
      def initialize(suffix, then_processor)
        @suffix = suffix
        @then_processor = then_processor

        freeze
      end

      def process(str, node, method_node)
        return unless str

        @then_processor.process(str.delete_suffix(@suffix), node, method_node)
      end
    end
  end
end

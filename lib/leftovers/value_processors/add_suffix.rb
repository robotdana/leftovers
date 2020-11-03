# frozen_string_literal: true

module Leftovers
  module ValueProcessors
    class AddSuffix
      def initialize(suffix, then_processor)
        @suffix = suffix
        @then_processor = then_processor

        freeze
      end

      def process(str, node, method_node)
        return unless str

        @then_processor.process("#{str}#{@suffix}", node, method_node)
      end
    end
  end
end

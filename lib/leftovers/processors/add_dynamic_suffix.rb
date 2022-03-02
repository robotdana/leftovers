# frozen_string_literal: true

module Leftovers
  module Processors
    class AddDynamicSuffix
      def initialize(suffix_processor, then_processor)
        @suffix_processor = suffix_processor
        @then_processor = then_processor

        freeze
      end

      def process(str, node, method_node, acc)
        return unless str

        suffixes = []
        @suffix_processor.process(nil, method_node, method_node, suffixes)

        suffixes.each do |suffix|
          @then_processor.process("#{str}#{suffix}", node, method_node, acc)
        end
      end

      freeze
    end
  end
end

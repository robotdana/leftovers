# frozen_string_literal: true

module Leftovers
  module Processors
    class AddDynamicSuffix
      include ComparableInstance

      def initialize(suffix_processor, then_processor)
        @suffix_processor = suffix_processor
        @then_processor = then_processor

        freeze
      end

      def process(str, current_node, matched_node, acc)
        return unless str

        suffixes = []
        @suffix_processor.process(nil, matched_node, matched_node, suffixes)

        suffixes.each do |suffix|
          @then_processor.process("#{str}#{suffix}", current_node, matched_node, acc)
        end
      end

      freeze
    end
  end
end

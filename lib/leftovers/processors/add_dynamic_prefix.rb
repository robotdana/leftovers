# frozen_string_literal: true

module Leftovers
  module Processors
    class AddDynamicPrefix
      include ComparableInstance

      def initialize(prefix_processor, then_processor)
        @prefix_processor = prefix_processor
        @then_processor = then_processor

        freeze
      end

      def process(str, current_node, matched_node, acc)
        return unless str

        prefixes = []
        @prefix_processor.process(nil, matched_node, matched_node, prefixes)

        prefixes.each do |prefix|
          @then_processor.process("#{prefix}#{str}", current_node, matched_node, acc)
        end
      end

      freeze
    end
  end
end

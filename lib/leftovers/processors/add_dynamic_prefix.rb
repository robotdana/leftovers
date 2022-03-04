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

      def process(str, node, method_node, acc)
        return unless str

        prefixes = []
        @prefix_processor.process(nil, method_node, method_node, prefixes)

        prefixes.each do |prefix|
          @then_processor.process("#{prefix}#{str}", node, method_node, acc)
        end
      end

      freeze
    end
  end
end

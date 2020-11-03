# frozen_string_literal: true

module Leftovers
  module ValueProcessors
    class AddDynamicPrefix
      def initialize(prefix_processor, then_processor)
        @prefix_processor = prefix_processor
        @then_processor = then_processor

        freeze
      end

      def process(str, node, method_node) # rubocop:disable Metrics/MethodLength
        return unless str

        prefixes = @prefix_processor.process(nil, method_node, method_node)
        if prefixes.is_a?(Array)
          prefixes.flatten!
          prefixes.compact!
          prefixes.uniq!

          prefixes.map do |prefix|
            @then_processor.process("#{prefix}#{str}", node, method_node)
          end
        else
          @then_processor.process("#{prefixes}#{str}", node, method_node)
        end
      end
    end
  end
end

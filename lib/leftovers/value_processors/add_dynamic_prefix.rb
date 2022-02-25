# frozen_string_literal: true

module Leftovers
  module ValueProcessors
    class AddDynamicPrefix
      def initialize(prefix_processor, then_processor)
        @prefix_processor = prefix_processor
        @then_processor = then_processor

        freeze
      end

      def process(str, node, method_node)
        return unless str

        prefixes = @prefix_processor.process(nil, method_node, method_node)

        Leftovers.map_or_self(prefixes) do |prefix|
          @then_processor.process("#{prefix}#{str}", node, method_node)
        end
      end
    end
  end
end

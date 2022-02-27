# frozen_string_literal: true

module Leftovers
  module ValueProcessors
    class AddDynamicSuffix
      def initialize(suffix_processor, then_processor)
        @suffix_processor = suffix_processor
        @then_processor = then_processor

        freeze
      end

      def process(str, node, method_node)
        return unless str

        suffixes = @suffix_processor.process(nil, method_node, method_node)

        Leftovers.map_or_self(suffixes) do |suffix|
          @then_processor.process("#{str}#{suffix}", node, method_node)
        end
      end

      freeze
    end
  end
end

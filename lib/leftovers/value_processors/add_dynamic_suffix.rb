# frozen_string_literal: true

module Leftovers
  module ValueProcessors
    class AddDynamicSuffix
      def initialize(suffix_processor, then_processor)
        @suffix_processor = suffix_processor
        @then_processor = then_processor

        freeze
      end

      def process(str, node, method_node) # rubocop:disable Metrics/MethodLength
        return unless str

        suffixes = @suffix_processor.process(nil, method_node, method_node)
        if suffixes.is_a?(Array)
          suffixes.flatten!
          suffixes.compact!
          suffixes.uniq!

          suffixes.map do |suffix|
            @then_processor.process("#{str}#{suffix}", node, method_node)
          end
        else
          @then_processor.process("#{str}#{suffixes}", node, method_node)
        end
      end
    end
  end
end

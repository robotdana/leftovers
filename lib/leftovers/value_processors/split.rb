# frozen_string_literal: true

module Leftovers
  module ValueProcessors
    class Split
      def initialize(split_on, then_processor)
        @split_on = split_on
        @then_processor = then_processor

        freeze
      end

      def process(str, node, method_node)
        return unless str

        str.split(@split_on).map do |substring|
          @then_processor.process(substring, node, method_node)
        end
      end
    end
  end
end

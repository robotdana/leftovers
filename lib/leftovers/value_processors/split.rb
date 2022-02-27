# frozen_string_literal: true

module Leftovers
  module ValueProcessors
    class Split
      def initialize(split_on, then_processor)
        @split_on = split_on
        @then_processor = then_processor

        freeze
      end

      def process(str, node, method_node, acc)
        return unless str

        str.split(@split_on).each do |sub_str|
          @then_processor.process(sub_str, node, method_node, acc)
        end
      end

      freeze
    end
  end
end

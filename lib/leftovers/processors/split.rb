# frozen_string_literal: true

module Leftovers
  module Processors
    class Split
      include ComparableInstance

      def initialize(split_on, then_processor)
        @split_on = split_on
        @then_processor = then_processor

        freeze
      end

      def process(str, current_node, matched_node, acc)
        return unless str

        str.split(@split_on).each do |sub_str|
          @then_processor.process(sub_str, current_node, matched_node, acc)
        end
      end

      freeze
    end
  end
end

# frozen_string_literal: true

module Leftovers
  module Processors
    class Downcase
      include ComparableInstance

      def initialize(then_processor)
        @then_processor = then_processor

        freeze
      end

      def process(str, current_node, matched_node, acc)
        return unless str

        @then_processor.process(str.downcase, current_node, matched_node, acc)
      end

      freeze
    end
  end
end

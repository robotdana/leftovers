# frozen_string_literal: true

module Leftovers
  module Processors
    class MatchCurrentNode
      include ComparableInstance

      attr_reader :matcher, :then_processor

      def initialize(matcher, then_processor)
        @matcher = matcher
        @then_processor = then_processor

        freeze
      end

      def process(str, current_node, matched_node, acc)
        return unless @matcher === current_node

        @then_processor.process(str, current_node, matched_node, acc)
      end

      freeze
    end
  end
end

# frozen_string_literal: true

module Leftovers
  module Processors
    class IfMatcher
      include ComparableInstance

      attr_reader :matcher, :then_processor

      def initialize(matcher, then_processor)
        @matcher = matcher
        @then_processor = then_processor

        freeze
      end

      def process(str, node, module_node, acc)
        return unless @matcher === node

        @then_processor.process(str, node, module_node, acc)
      end

      freeze
    end
  end
end

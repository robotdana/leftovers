# frozen_string_literal: true

module Leftovers
  module ValueProcessors
    class Demodulize
      def initialize(then_processor)
        @then_processor = then_processor

        freeze
      end

      def process(str, node, method_node)
        return unless str

        @then_processor.process(str.demodulize, node, method_node)
      end
    end
  end
end

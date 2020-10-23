# frozen-string-literal: true

module Leftovers
  module ValueProcessors
    class EachValue
      def initialize(then_processors)
        @then_processors = then_processors
      end

      def process(node, method_node, str)
        @then_processors.map do |then_processor|
          then_processor.process(node, method_node, str)
        end
      end
    end
  end
end

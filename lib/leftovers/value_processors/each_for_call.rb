# frozen-string-literal: true

module Leftovers
  module ValueProcessors
    class EachForCall
      def initialize(then_processors)
        @then_processors = then_processors
      end

      def process(str, node, method_node)
        then_processors.map do |then_processor|
          then_processor.process(str, node, method_node)
        end
      end
    end
  end
end

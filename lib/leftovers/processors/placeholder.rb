# frozen-string-literal: true

module Leftovers
  module Processors
    class Placeholder
      def processor=(value)
        @processor = value

        freeze
      end

      def process(str, node, method_node, acc)
        @processor.process(str, node, method_node, acc)
      end

      freeze
    end
  end
end

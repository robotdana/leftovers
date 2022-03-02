# frozen-string-literal: true

# TODO: find a way for this to remove itself from the chain
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

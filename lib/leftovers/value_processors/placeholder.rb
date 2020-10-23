# frozen-string-literal: true

# TODO: find a way for this to remove itself from the chain
module Leftovers
  module ValueProcessors
    class Placeholder
      attr_reader :processor

      def processor=(value)
        @processor = value

        freeze
      end

      def process(str, node, method_node)
        @processor.process(str, node, method_node)
      end
    end
  end
end

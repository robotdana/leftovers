# frozen-string-literal: true

module Leftovers
  module DynamicProcessors
    class Call
      def initialize(matcher, processor)
        @matcher = matcher
        @processor = processor
      end

      def process(node, file)
        return unless @matcher === node

        call = @processor.process(nil, node, node)
        return unless call

        file.calls << call
      end
    end
  end
end

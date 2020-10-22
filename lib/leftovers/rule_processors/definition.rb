# frozen-string-literal: true

module Leftovers
  module RuleProcessors
    class Definition
      def initialize(matcher, processor)
        @matcher = matcher
        @processor = processor
      end

      def process(node, file)
        return if node.keep_line?
        return unless @matcher === node

        definition = @processor.process(node)
        return unless definition

        file.definitions << definition
      end
    end
  end
end

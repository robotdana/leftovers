# frozen-string-literal: true

module Leftovers
  module RuleProcessors
    class CallDefinition
      def initialize(matcher, call_processor, definition_processor)
        @matcher = matcher
        @call_processor = call_processor
        @definition_processor = definition_processor
      end

      def process(node, file)
        return unless @matcher === node

        call = @call_processor.process(node)
        (file.calls << call) if call

        return if node.keep_line?

        definition = @definition_processor.process(node)
        return unless definition

        file.definitions << definition
      end
    end
  end
end

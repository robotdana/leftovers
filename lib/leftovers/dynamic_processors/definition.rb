# frozen-string-literal: true

module Leftovers
  module DynamicProcessors
    class Definition
      # :nocov:
      using ::Leftovers::Backports::SetCaseEq if defined?(::Leftovers::Backports::SetCaseEq)
      # :nocov:

      def initialize(matcher, processor)
        @matcher = matcher
        @processor = processor
      end

      def process(node, file)
        return if node.keep_line?
        return unless @matcher === node

        definition = @processor.process(nil, node, node)
        return unless definition

        file.definitions << definition
      end
    end
  end
end

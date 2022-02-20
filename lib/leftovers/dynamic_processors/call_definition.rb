# frozen-string-literal: true

module Leftovers
  module DynamicProcessors
    class CallDefinition
      def initialize(matcher, call_processor, definition_processor)
        @matcher = matcher
        @call_processor = call_processor
        @definition_processor = definition_processor
      end

      def process(node, file) # rubocop:disable Metrics/MethodLength
        return unless @matcher === node

        calls = @call_processor.process(nil, node, node)

        ::Leftovers.each_or_self(calls) do |call|
          file.calls << call
        end

        return if node.keep_line?

        definitions = @definition_processor.process(nil, node, node)
        ::Leftovers.each_or_self(definitions) do |definition|
          if definition.is_a?(DefinitionNodeSet)
            file.add_definition_set(definition)
          else
            file.add_definition(definition, loc: definition.loc)
          end
        end
      end
    end
  end
end

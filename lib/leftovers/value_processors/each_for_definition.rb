# frozen-string-literal: true

require_relative '../definition_set'

module Leftovers
  module ValueProcessors
    class EachForDefinition
      def initialize(then_processors)
        @then_processors = then_processors
      end

      def process(str, node, method_node) # rubocop:disable Metrics/MethodLength
        definitions = @then_processors.map do |then_processor|
          processed = then_processor.process(str, node, method_node)
          return if processed == :keep # rubocop:disable Lint/NonLocalExitFromIterator

          processed
        end

        definitions.flatten!
        definitions.compact!

        ::Leftovers::DefinitionSet.new(
          definitions,
          location: node.loc.expression,
          method_node: method_node
        )
      end
    end
  end
end

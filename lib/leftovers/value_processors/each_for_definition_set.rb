# frozen-string-literal: true

module Leftovers
  module ValueProcessors
    class EachForDefinitionSet
      def initialize(then_processors)
        @then_processors = then_processors

        freeze
      end

      def process(str, node, method_node) # rubocop:disable Metrics/MethodLength
        definitions = @then_processors.map do |then_processor|
          processed = then_processor.process(str, node, method_node)
          return if processed == :keep # rubocop:disable Lint/NonLocalExitFromIterator

          processed
        end

        definitions.flatten!
        definitions.compact!

        return definitions.first if definitions.length <= 1

        ::Leftovers::DefinitionSet.new(
          definitions,
          location: node.loc.expression,
          method_node: method_node
        )
      end
    end
  end
end

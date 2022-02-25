# frozen-string-literal: true

module Leftovers
  module ValueProcessors
    class EachForDefinitionSet
      def initialize(then_processors)
        @then_processors = then_processors

        freeze
      end

      def process(str, node, method_node)
        definitions = Leftovers.map_or_self(@then_processors) do |then_processor|
          then_processor.process(str, node, method_node)
        end

        return definitions unless definitions.is_a?(Array)

        ::Leftovers::DefinitionNodeSet.new(definitions)
      end
    end
  end
end

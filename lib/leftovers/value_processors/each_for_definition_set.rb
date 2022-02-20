# frozen-string-literal: true

module Leftovers
  module ValueProcessors
    class EachForDefinitionSet
      def initialize(then_processors)
        @then_processors = then_processors

        freeze
      end

      def process(str, node, method_node)
        definitions = @then_processors.map do |then_processor|
          then_processor.process(str, node, method_node)
        end

        definitions.flatten!
        definitions.compact!

        return definitions.first if definitions.length <= 1

        ::Leftovers::DefinitionNodeSet.new(definitions)
      end
    end
  end
end

# frozen-string-literal: true

module Leftovers
  module Processors
    class EachForDefinitionSet
      def initialize(then_processors)
        @then_processors = then_processors

        freeze
      end

      def process(str, node, method_node, acc)
        set = ::Leftovers::DefinitionNodeSet.new

        @then_processors.each do |then_processor|
          then_processor.process(str, node, method_node, set)
        end

        if set.definitions.length == 1
          acc.add_definition_node set.definitions.first
        else
          acc.add_definition_set set
        end
      end

      freeze
    end
  end
end

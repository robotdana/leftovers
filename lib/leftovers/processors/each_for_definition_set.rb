# frozen-string-literal: true

module Leftovers
  module Processors
    class EachForDefinitionSet
      include ComparableInstance

      attr_reader :processors

      def initialize(processors)
        @processors = processors

        freeze
      end

      def process(str, current_node, matched_node, acc)
        set = ::Leftovers::DefinitionNodeSet.new

        @processors.each do |processor|
          processor.process(str, current_node, matched_node, set)
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

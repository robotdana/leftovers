# frozen_string_literal: true

module Leftovers
  module Processors
    class EachForDefinitionSet
      include ComparableInstance

      attr_reader :processors

      def initialize(processors)
        @processors = processors

        freeze
      end

      def process(str, current_node, matched_node, acc) # rubocop:disable Metrics/MethodLength
        set = DefinitionNodeSet.new

        @processors.each do |processor|
          processor.process(str, current_node, matched_node, set)
        end

        case set.definitions.length
        when 1
          acc.add_definition_node set.definitions.first
        when 0
          nil
        else
          acc.add_definition_set set
        end
      end

      freeze
    end
  end
end

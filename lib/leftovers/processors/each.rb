# frozen_string_literal: true

module Leftovers
  module Processors
    class Each
      include ComparableInstance

      attr_reader :processors

      def initialize(processors)
        @processors = processors

        freeze
      end

      def process(str, current_node, matched_node, acc)
        @processors.each do |processor|
          processor.process(str, current_node, matched_node, acc)
        end
      end

      freeze
    end
  end
end

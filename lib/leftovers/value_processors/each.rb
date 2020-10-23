# frozen_string_literal: true

module Leftovers
  module ValueProcessors
    class Each
      attr_reader :processors

      def initialize(processors)
        @processors = processors
      end

      def process(str, node, method_node)
        @processors.flat_map do |processor|
          processor.process(str, node, method_node)
        end
      end
    end
  end
end

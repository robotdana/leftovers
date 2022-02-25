# frozen_string_literal: true

module Leftovers
  module ValueProcessors
    class Each
      attr_reader :processors

      def initialize(processors)
        @processors = processors

        freeze
      end

      def process(str, node, method_node)
        Leftovers.map_or_self(@processors) do |processor|
          processor.process(str, node, method_node)
        end
      end
    end
  end
end

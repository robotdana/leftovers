# frozen_string_literal: true

module Leftovers
  module MethodProcessors
    class Each
      attr_reader :processors

      def initialize(processors)
        @processors = processors
      end

      def process(method_node)
        @processors.flat_map do |processor|
          processor.process(method_node)
        end
      end
    end
  end
end

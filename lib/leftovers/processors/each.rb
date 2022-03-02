# frozen_string_literal: true

module Leftovers
  module Processors
    class Each
      attr_reader :processors

      def initialize(processors)
        @processors = processors

        freeze
      end

      def process(str, node, method_node, acc)
        @processors.each do |processor|
          processor.process(str, node, method_node, acc)
        end
      end

      freeze
    end
  end
end

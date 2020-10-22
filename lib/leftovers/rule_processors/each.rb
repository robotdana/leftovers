# frozen-string-literal: true

module Leftovers
  module RuleProcessors
    class Each
      attr_reader :processors

      def initialize(processors)
        @processors = processors
      end

      def process(node, file)
        @processors.each do |processor|
          processor.process(node, file)
        end
      end
    end
  end
end

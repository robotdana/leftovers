# frozen-string-literal: true

module Leftovers
  module DynamicProcessors
    class SetPrivacy
      def initialize(matcher, processor, to)
        @matcher = matcher
        @processor = processor
        @to = to
      end

      def process(node, file)
        return unless @matcher === node

        set_privacy = @processor.process(nil, node, node)

        ::Leftovers.each_or_self(set_privacy) do |name|
          file.set_privacy(name, @to)
        end
      end
    end
  end
end

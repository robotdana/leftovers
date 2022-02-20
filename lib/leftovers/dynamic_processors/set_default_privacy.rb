# frozen-string-literal: true

module Leftovers
  module DynamicProcessors
    class SetDefaultPrivacy
      def initialize(matcher, to)
        @matcher = matcher
        @to = to
      end

      def process(node, file)
        return unless @matcher === node

        file.default_method_privacy = @to
      end
    end
  end
end

# frozen-string-literal: true

module Leftovers
  module ProcessorBuilders
    module KeywordArgument
      def self.build(pattern, then_processor)
        matcher = ::Leftovers::MatcherBuilders::NodeName.build(pattern)
        return unless matcher

        ::Leftovers::ValueProcessors::KeywordArgument.new(matcher, then_processor)
      end
    end
  end
end

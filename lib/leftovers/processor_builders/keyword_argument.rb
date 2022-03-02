# frozen-string-literal: true

module Leftovers
  module ProcessorBuilders
    module KeywordArgument
      def self.build(pattern, then_processor)
        ::Leftovers::Processors::KeywordArgument.new(
          ::Leftovers::MatcherBuilders::NodePairName.build(pattern),
          then_processor
        )
      end
    end
  end
end

# frozen_string_literal: true

module Leftovers
  module ProcessorBuilders
    module KeywordArgument
      def self.build(pattern, then_processor)
        Processors::KeywordArgument.new(
          MatcherBuilders::NodePairKey.build(
            MatcherBuilders::NodeName.build(pattern)
          ),
          then_processor
        )
      end
    end
  end
end

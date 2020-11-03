# frozen-string-literal: true

module Leftovers
  module MatcherBuilders
    module NodeHasKeywordArgument
      def self.build(keywords, value_matcher)
        value_matcher = ::Leftovers::MatcherBuilders::NodePairValue.build(value_matcher)
        keyword_matcher = ::Leftovers::MatcherBuilders::NodePairName.build(keywords)

        pair_matcher = ::Leftovers::MatcherBuilders::And.build([
          keyword_matcher, value_matcher
        ])
        # :nocov:
        raise unless pair_matcher

        # :nocov:

        ::Leftovers::Matchers::NodeHasAnyKeywordArgument.new(pair_matcher)
      end
    end
  end
end

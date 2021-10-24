# frozen-string-literal: true

module Leftovers
  module MatcherBuilders
    module NodeHasKeywordArgument
      class << self
        def build(keywords, value_matcher)
          value_matcher = ::Leftovers::MatcherBuilders::NodePairValue.build(value_matcher)
          keywords = process_keywords(keywords)
          keyword_matcher = ::Leftovers::MatcherBuilders::NodePairName.build(keywords)

          pair_matcher = ::Leftovers::MatcherBuilders::And.build([
            keyword_matcher, value_matcher
          ])
          # :nocov:
          raise unless pair_matcher

          # :nocov:

          ::Leftovers::Matchers::NodeHasAnyKeywordArgument.new(pair_matcher)
        end

        private

        def process_keywords(keywords)
          if keywords.is_a?(Array)
            keywords unless keywords.include?('**')
          else
            keywords unless keywords == '**'
          end
        end
      end
    end
  end
end

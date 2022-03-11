# frozen-string-literal: true

module Leftovers
  module MatcherBuilders
    module NodeHasKeywordArgument
      class << self
        def build(keywords, value_matcher)
          value_matcher = ::Leftovers::MatcherBuilders::NodePairValue.build(value_matcher)
          keyword_matcher = build_keyword_matcher(keywords)
          pair_matcher = ::Leftovers::MatcherBuilders::And.build([keyword_matcher, value_matcher])

          return unless pair_matcher

          ::Leftovers::Matchers::NodeHasAnyKeywordArgument.new(pair_matcher)
        end

        private

        def build_keyword_matcher(keywords)
          if ::Leftovers.each_or_self(keywords).include?('**')
            ::Leftovers::Matchers::NodeType.new(:pair)
          else
            ::Leftovers::MatcherBuilders::NodePairKey.build(
              ::Leftovers::MatcherBuilders::Node.build(keywords)
            )
          end
        end
      end
    end
  end
end

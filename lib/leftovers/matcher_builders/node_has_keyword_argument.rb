# frozen-string-literal: true

module Leftovers
  module MatcherBuilders
    module NodeHasKeywordArgument
      class << self
        def build(keywords, value_matcher) # rubocop:disable Metrics/MethodLength
          value_matcher = ::Leftovers::MatcherBuilders::NodePairValue.build(value_matcher)
          keyword_matcher = if ::Leftovers.each_or_self(keywords).any? { |x| x == '**' }
            ::Leftovers::Matchers::NodeType.new(:pair)
          else
            ::Leftovers::MatcherBuilders::NodePairName.build(keywords)
          end

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
end

# frozen-string-literal: true

module Leftovers
  module MatcherBuilders
    module AndNot
      class << self
        def build(positive_matcher, negative_matcher)
          ::Leftovers::MatcherBuilders::And.build([
            positive_matcher,
            ::Leftovers::MatcherBuilders::Unless.build(negative_matcher)
          ])
        end
      end
    end
  end
end

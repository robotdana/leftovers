# frozen-string-literal: true

require_relative 'and'
require_relative 'unless'

module Leftovers
  module MatcherBuilders
    module AndNot
      def self.build(positive_matcher, negative_matcher)
        ::Leftovers::MatcherBuilders::And.build([
          positive_matcher,
          ::Leftovers::MatcherBuilders::Unless.build(negative_matcher)
        ])
      end
    end
  end
end

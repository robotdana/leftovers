# frozen-string-literal: true

module Leftovers
  module MatcherBuilders
    module NodePairKey
      def self.build(key_matcher)
        return unless key_matcher

        ::Leftovers::MatcherBuilders::And.build([
          ::Leftovers::Matchers::NodeType.new(:pair),
          ::Leftovers::Matchers::NodePairKey.new(key_matcher)
        ])
      end
    end
  end
end

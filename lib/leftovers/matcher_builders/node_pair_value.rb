# frozen-string-literal: true

module Leftovers
  module MatcherBuilders
    module NodePairValue
      def self.build(value_matcher)
        return unless value_matcher

        ::Leftovers::MatcherBuilders::And.build([
          ::Leftovers::Matchers::NodeType.new(:pair),
          ::Leftovers::Matchers::NodePairValue.new(value_matcher)
        ])
      end
    end
  end
end

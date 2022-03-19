# frozen-string-literal: true

module Leftovers
  module MatcherBuilders
    module NodePairValue
      def self.build(value_matcher)
        return unless value_matcher

        And.build([
          Matchers::NodeType.new(:pair),
          Matchers::NodePairValue.new(value_matcher)
        ])
      end
    end
  end
end

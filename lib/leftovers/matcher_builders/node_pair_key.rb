# frozen-string-literal: true

module Leftovers
  module MatcherBuilders
    module NodePairKey
      def self.build(key_matcher)
        return unless key_matcher

        And.build([
          Matchers::NodeType.new(:pair),
          Matchers::NodePairKey.new(key_matcher)
        ])
      end
    end
  end
end

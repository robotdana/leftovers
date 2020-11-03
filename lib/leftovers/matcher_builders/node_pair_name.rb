# frozen-string-literal: true

module Leftovers
  module MatcherBuilders
    module NodePairName
      def self.build(name_pattern)
        matcher = ::Leftovers::MatcherBuilders::Name.build(name_pattern)

        return unless matcher

        ::Leftovers::MatcherBuilders::And.build([
          ::Leftovers::Matchers::NodeType.new(:pair),
          ::Leftovers::Matchers::NodeName.new(matcher)
        ])
      end
    end
  end
end

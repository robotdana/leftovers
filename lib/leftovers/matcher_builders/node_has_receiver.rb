# frozen-string-literal: true

module Leftovers
  module MatcherBuilders
    module NodeHasReceiver
      class << self
        def build(pattern)
          matcher = ::Leftovers::MatcherBuilders::NodeValue.build(pattern)

          ::Leftovers::Matchers::NodeHasReceiver.new(matcher) if matcher
        end
      end
    end
  end
end

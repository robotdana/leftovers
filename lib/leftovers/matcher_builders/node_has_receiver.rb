# frozen-string-literal: true

module Leftovers
  module MatcherBuilders
    module NodeHasReceiver
      class << self
        def build(pattern) # rubocop:disable Metrics/MethodLength
          case pattern
          when true
            ::Leftovers::Matchers::NodeHasAnyReceiver
          when false, :_leftovers_nil_value
            ::Leftovers::Matchers::Not.new(
              ::Leftovers::Matchers::NodeHasAnyReceiver
            )
          else
            matcher = ::Leftovers::MatcherBuilders::NodeValue.build(pattern)

            ::Leftovers::Matchers::NodeHasReceiver.new(matcher) if matcher
          end
        end
      end
    end
  end
end

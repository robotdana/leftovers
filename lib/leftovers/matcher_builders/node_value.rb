# frozen-string-literal: true

module Leftovers
  module MatcherBuilders
    module NodeValue
      class << self
        def build(pattern) # rubocop:disable Metrics/MethodLength
          ::Leftovers::MatcherBuilders::Or.each_or_self(pattern) do |pat|
            case pat
            when ::Integer, true, false, nil
              ::Leftovers::Matchers::NodeScalarValue.new(pat)
            when ::String
              ::Leftovers::MatcherBuilders::NodeName.build(pat)
            when ::Hash
              build_from_hash(**pat)
            # :nocov:
            else raise
              # :nocov:
            end
          end
        end

        private

        def build_from_hash( # rubocop:disable Metrics/MethodLength, Metrics/ParameterLists
          at: nil, has_value: nil,
          match: nil, has_prefix: nil, has_suffix: nil,
          type: nil,
          has_receiver: nil,
          unless_arg: nil
        )
          matcher = ::Leftovers::MatcherBuilders::And.build([
            ::Leftovers::MatcherBuilders::NodeHasArgument.build(
              at: at, has_value: has_value
            ),
            ::Leftovers::MatcherBuilders::NodeName.build(
              match: match, has_prefix: has_prefix, has_suffix: has_suffix
            ),
            ::Leftovers::MatcherBuilders::NodeType.build(type),
            ::Leftovers::MatcherBuilders::NodeHasReceiver.build(has_receiver)
          ])

          ::Leftovers::MatcherBuilders::AndNot.build(
            matcher, ::Leftovers::MatcherBuilders::NodeValue.build(unless_arg)
          )
        end
      end
    end
  end
end

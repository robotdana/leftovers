# frozen-string-literal: true

module Leftovers
  module MatcherBuilders
    module NodeHasArgument
      def self.build(patterns) # rubocop:disable Metrics/MethodLength
        ::Leftovers::MatcherBuilders::Or.each_or_self(patterns) do |pat|
          case pat
          when ::String
            ::Leftovers::MatcherBuilders::NodeHasKeywordArgument.build(pat, nil)
          when ::Integer
            ::Leftovers::MatcherBuilders::NodeHasPositionalArgument.build(pat, nil)
          when ::Hash
            build_from_hash(**pat)
          # :nocov:
          else
            raise
            # :nocov:
          end
        end
      end

      def self.separate_argument_types(at) # rubocop:disable Metrics/MethodLength
        keys = []
        positions = []

        ::Leftovers.each_or_self(at) do |k|
          case k
          when '*'
            positions << k
          when ::String, ::Hash
            keys << k
          when ::Integer
            positions << k
          # :nocov:
          else raise
            # :nocov:
          end
        end

        keys = nil if keys.empty?
        positions = nil if positions.empty?

        [keys, positions]
      end

      def self.build_from_hash( # rubocop:disable Metrics/MethodLength
        at: nil,
        has_value: nil,
        unless_arg: nil
      )
        keys, positions = separate_argument_types(at)

        value_matcher = ::Leftovers::MatcherBuilders::ArgumentNodeValue.build(has_value)
        matcher = if (keys && positions) || (!keys && !positions)
          ::Leftovers::MatcherBuilders::Or.build([
            ::Leftovers::MatcherBuilders::NodeHasPositionalArgument.build(positions, value_matcher),
            ::Leftovers::MatcherBuilders::NodeHasKeywordArgument.build(keys, value_matcher)
          ])
        elsif keys
          ::Leftovers::MatcherBuilders::NodeHasKeywordArgument.build(keys, value_matcher)
        elsif positions
          ::Leftovers::MatcherBuilders::NodeHasPositionalArgument.build(positions, value_matcher)
          # :nocov:
        else raise
          # :nocov:
        end

        ::Leftovers::MatcherBuilders::AndNot.build(
          matcher, ::Leftovers::MatcherBuilders::NodeHasArgument.build(unless_arg)
        )
      end
    end
  end
end

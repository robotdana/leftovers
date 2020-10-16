# frozen-string-literal: true

require_relative 'node'
require_relative 'node_name'
require_relative 'and'
require_relative '../matchers/node_has_keyword_argument'
require_relative '../matchers/node_has_positional_argument_length_minimum'
require_relative '../matchers/node_has_positional_argument'
require_relative '../matchers/node_has_positional_argument_at_position'
require_relative '../matchers/node_pair_value'

module Leftovers
  module MatcherBuilders
    module NodeHasArgument
      def self.build(patterns, default = true) # rubocop:disable Metrics/MethodLength
        ::Leftovers::MatcherBuilders::And.each_or_self(patterns, default) do |pat|
          case pat
          when ::String
            ::Leftovers::Matchers::NodeHasKeywordArgument.new(
              ::Leftovers::MatcherBuilders::NodeName.build(pat)
            )
          when ::Integer
            ::Leftovers::Matchers::NodeHasPositionalArgumentLengthMinimum.new(pat)
          when ::Hash
            build_from_hash(**pat)
          else
            raise ::Leftovers::ConfigError, "Invalid value #{pat.inspect} for has_argument"
          end
        end
      end

      def self.build_from_hash(at: nil, value: nil, unless_arg: nil) # rubocop:disable Metrics/MethodLength, Metrics/PerceivedComplexity, Metrics/CyclomaticComplexity, Metrics/AbcSize
        at = Array(at)
        keys = at.reject { |k| k.is_a?(Integer) }
        index = at.select { |i| i.is_a?(Integer) }
        keys = nil if keys.empty?
        index = nil if index.empty?

        keyword_matcher = ::Leftovers::MatcherBuilders::NodeName.build(keys, nil)
        value_matcher = ::Leftovers::MatcherBuilders::Node.build(value, nil)

        has_positional_argument = build_node_has_argument_at_position(index, value_matcher) if index
        unless index && !keys
          has_keyword_argument = build_node_has_keyword_argument(keyword_matcher, value_matcher)
        end

        matcher = if index && !keys
          has_positional_argument
        elsif keys && !index
          has_keyword_argument
        elsif keys && index
          x = ::Leftovers::MatcherBuilders::Or.build([
            has_keyword_argument,
            has_positional_argument
          ], nil)

          x
        else
          build_node_has_any_argument(has_keyword_argument, value_matcher)
        end

        if unless_arg
          ::Leftovers::MatcherBuilders::And.build([
            matcher,
            ::Leftovers::Matchers::Not.new(
              ::Leftovers::MatcherBuilders::NodeHasArgument.build(unless_arg, nil)
            )
          ])
        else
          matcher
        end
      end

      def self.build_node_has_argument_at_position(index, value_matcher)
        ::Leftovers::MatcherBuilders::Or.each_or_self(index, nil) do |position|
          ::Leftovers::Matchers::NodeHasPositionalArgumentAtPosition.new(
            position - 1, value_matcher
          )
        end
      end

      def self.build_node_has_any_argument(has_keyword_argument, value_matcher)
        ::Leftovers::MatcherBuilders::Or.build([
          has_keyword_argument,
          ::Leftovers::Matchers::NodeHasPositionalArgument.new(value_matcher)
        ])
      end

      def self.build_node_has_keyword_argument(keyword_matcher, value_matcher)
        value_matcher = ::Leftovers::Matchers::NodePairValue.new(value_matcher) if value_matcher

        ::Leftovers::Matchers::NodeHasKeywordArgument.new(
          ::Leftovers::MatcherBuilders::And.build([keyword_matcher, value_matcher])
        )
      end
    end
  end
end

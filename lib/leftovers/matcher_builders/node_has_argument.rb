# frozen-string-literal: true

require_relative 'node'
require_relative 'node_name'
require_relative 'and'
require_relative '../matchers/node_has_keyword_argument'
require_relative '../matchers/node_has_positional_argument_length_minimum'
require_relative '../matchers/node_has_positional_argument'
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
            raise 'no'
          end
        end
      end

      def self.build_from_hash(keyword: nil, value: nil, **reserved_kw) # rubocop:disable Metrics/MethodLength
        unless_arg = reserved_kw.delete(:unless) # keywords as kwargs when
        unless reserved_kw.empty?
          rest_kw = reserved_kw.keys.join(', ')
          raise Leftovers::ConfigError, "Unrecognized has_argument keyword(s) #{rest_kw}"
        end

        keyword_matcher = ::Leftovers::MatcherBuilders::NodeName.build(keyword, nil)
        value_matcher = ::Leftovers::MatcherBuilders::Node.build(value, nil)

        has_keyword_argument = build_node_has_keyword_argument(keyword_matcher, value_matcher)
        unless keyword_matcher
          has_argument = build_node_has_any_argument(has_keyword_argument, value_matcher)
        end

        matcher = has_argument || has_keyword_argument

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

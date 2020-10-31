# frozen-string-literal: true

module Leftovers
  module MatcherBuilders
    module Node
      def self.build(pattern) # rubocop:disable Metrics/MethodLength
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

      def self.build_from_hash( # rubocop:disable Metrics/ParameterLists, Metrics/MethodLength
        names: nil, match: nil, has_prefix: nil, has_suffix: nil,
        paths: nil,
        type: nil,
        has_arguments: nil,
        unless_arg: nil
      )
        ::Leftovers::MatcherBuilders::And.build([
          ::Leftovers::MatcherBuilders::NodeName.build([
            names,
            { match: match, has_prefix: has_prefix, has_suffix: has_suffix }.compact
          ]),
          ::Leftovers::MatcherBuilders::NodeType.build(type),
          ::Leftovers::MatcherBuilders::NodePath.build(paths),
          ::Leftovers::MatcherBuilders::NodeHasArgument.build(has_arguments),
          ::Leftovers::MatcherBuilders::Unless.build(
            (::Leftovers::MatcherBuilders::Node.build(unless_arg) if unless_arg)
          )
        ])
      end
    end
  end
end

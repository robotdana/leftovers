# frozen_string_literal: true

module Leftovers
  module MatcherBuilders
    module Rule
      def self.build(names: nil, paths: nil, has_arguments: nil, unless_arg: nil) # rubocop:disable Metrics/MethodLength
        name_matcher = ::Leftovers::MatcherBuilders::NodeName.build(names)
        path_matcher = ::Leftovers::MatcherBuilders::NodePath.build(paths)
        has_argument_matcher = ::Leftovers::MatcherBuilders::NodeHasArgument.build(
          has_arguments
        )
        unless_matcher = ::Leftovers::MatcherBuilders::Unless.build(
          (::Leftovers::MatcherBuilders::Rule.build(**unless_arg) if unless_arg)
        )

        ::Leftovers::MatcherBuilders::And.build([
          name_matcher, path_matcher, has_argument_matcher, unless_matcher
        ])
      end
    end
  end
end

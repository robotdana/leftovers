# frozen_string_literal: true

require_relative 'node_name'
require_relative 'node_path'
require_relative 'node_has_argument'

require_relative 'and'

require_relative '../matchers/not'

module Leftovers
  module MatcherBuilders
    module Rule
      def self.build(names: nil, paths: nil, has_arguments: nil, unless_arg: nil) # rubocop:disable Metrics/MethodLength
        name_matcher = ::Leftovers::MatcherBuilders::NodeName.build(names, nil)
        path_matcher = ::Leftovers::MatcherBuilders::NodePath.build(paths, nil)
        has_argument_matcher = ::Leftovers::MatcherBuilders::NodeHasArgument.build(
          has_arguments, nil
        )
        unless_matcher = if unless_arg
          ::Leftovers::Matchers::Not.new(
            ::Leftovers::MatcherBuilders::Rule.build(**unless_arg)
          )
        end

        ::Leftovers::MatcherBuilders::And.build([
          name_matcher, path_matcher, has_argument_matcher, unless_matcher
        ], true)
      end
    end
  end
end

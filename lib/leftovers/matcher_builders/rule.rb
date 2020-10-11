# frozen_string_literal: true

require_relative 'node_name'
require_relative 'node_path'
require_relative 'node_has_argument'

require_relative 'and'

require_relative '../matchers/not'

module Leftovers
  module MatcherBuilders
    module Rule
      def self.build(name: nil, names: nil, path: nil, paths: nil, has_argument: nil, **reserved_kw) # rubocop:disable Metrics/ParameterLists, Metrics/PerceivedComplexity, Metrics/CyclomaticComplexity, Metrics/MethodLength
        unless_arg = reserved_kw.delete(:unless) # keywords as kwargs when
        unless reserved_kw.empty?
          raise Leftovers::ConfigError, "Unrecognized keyword(s) #{reserved_kw.keys.join(', ')}"
        end
        raise Leftovers::ConfigError, 'Only use one of name/names' if name && names
        raise Leftovers::ConfigError, 'Only use one of path/paths' if path && paths

        name_matcher = ::Leftovers::MatcherBuilders::NodeName.build(name || names, nil)
        path_matcher = ::Leftovers::MatcherBuilders::NodePath.build(path || paths, nil)
        has_argument_matcher = ::Leftovers::MatcherBuilders::NodeHasArgument.build(
          has_argument, nil
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

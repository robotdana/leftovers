# frozen-string-literal: true

require_relative 'fallback'
require_relative 'path'
require_relative '../matchers/node_path'

module Leftovers
  module MatcherBuilders
    module NodePath
      def self.build(path_pattern, default = true)
        matcher = ::Leftovers::MatcherBuilders::Path.build(path_pattern, nil)
        return ::Leftovers::Matchers::NodePath.new(matcher) if matcher

        ::Leftovers::MatcherBuilders::Fallback.build(default)
      end
    end
  end
end

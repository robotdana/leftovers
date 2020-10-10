# frozen-string-literal: true

require_relative 'fallback_matcher'
require_relative 'path_matcher'
require_relative '../matchers/node_path'

module Leftovers
  module Builders
    module NodePathMatcher
      def self.build(path_pattern, default = true)
        matcher = ::Leftovers::Builders::PathMatcher.build(path_pattern, nil)
        return matcher if matcher == ::Leftovers::Matchers::Anything

        return ::Leftovers::Matchers::NodePath.new(matcher) if matcher

        ::Leftovers::Builders::FallbackMatcher.build(default)
      end
    end
  end
end

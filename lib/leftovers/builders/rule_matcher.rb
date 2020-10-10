# frozen_string_literal: true

require_relative 'node_name_matcher'
require_relative 'node_path_matcher'
require_relative 'fallback_matcher'

require_relative '../matchers/send'

module Leftovers
  module Builders
    module RuleMatcher
      def self.build(name_pattern, path_pattern, default = true) # rubocop:disable Metrics/MethodLength
        name_matcher = ::Leftovers::Builders::NodeNameMatcher.build(name_pattern, nil)
        path_matcher = ::Leftovers::Builders::NodePathMatcher.build(path_pattern, nil)
        if name_matcher && path_matcher
          return ::Leftovers::Matchers::Send.new(name_matcher, path_matcher)
        end

        name_matcher || path_matcher || ::Leftovers::Builders::Fallback.build(default)
      end
    end
  end
end

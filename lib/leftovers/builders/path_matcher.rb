# frozen-string-literal: true

require_relative 'fallback_matcher'

module Leftovers
  module Builders
    module PathMatcher
      def self.build(path_pattern, default = nil)
        if path_pattern.nil? || path_pattern.empty?
          return ::Leftovers::Builders::FallbackMatcher.build(default)
        end

        ::FastIgnore.new(include_rules: path_pattern, gitignore: false, root: Leftovers.pwd)
      end
    end
  end
end

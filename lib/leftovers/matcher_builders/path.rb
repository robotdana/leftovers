# frozen-string-literal: true

require_relative 'fallback'
require 'fast_ignore'

module Leftovers
  module MatcherBuilders
    module Path
      def self.build(path_pattern, default = nil)
        if path_pattern.nil? || path_pattern.empty?
          return ::Leftovers::MatcherBuilders::Fallback.build(default)
        end

        ::FastIgnore.new(include_rules: path_pattern, gitignore: false, root: Leftovers.pwd)
      end
    end
  end
end

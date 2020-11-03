# frozen-string-literal: true

require 'fast_ignore'

module Leftovers
  module MatcherBuilders
    module Path
      def self.build(path_pattern)
        return if path_pattern.nil? || path_pattern.empty?

        ::FastIgnore.new(include_rules: path_pattern, gitignore: false, root: Leftovers.pwd)
      end
    end
  end
end

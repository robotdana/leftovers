# frozen_string_literal: true

module Leftovers
  module MatcherBuilders
    module NodePath
      def self.build(path_pattern)
        matcher = Path.build(path_pattern)

        Matchers::NodePath.new(matcher) if matcher
      end
    end
  end
end

# frozen-string-literal: true

module Leftovers
  module MatcherBuilders
    module NodePath
      def self.build(path_pattern)
        matcher = Path.build(path_pattern)
        return unless matcher

        Matchers::NodePath.new(matcher)
      end
    end
  end
end

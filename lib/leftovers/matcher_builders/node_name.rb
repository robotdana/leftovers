# frozen-string-literal: true

module Leftovers
  module MatcherBuilders
    module NodeName
      def self.build(name_pattern)
        matcher = Name.build(name_pattern)

        return unless matcher

        Matchers::NodeName.new(matcher)
      end
    end
  end
end

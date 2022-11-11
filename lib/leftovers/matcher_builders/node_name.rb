# frozen_string_literal: true

module Leftovers
  module MatcherBuilders
    module NodeName
      def self.build(name_pattern)
        matcher = Name.build(name_pattern)

        Matchers::NodeName.new(matcher) if matcher
      end
    end
  end
end

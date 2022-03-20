# frozen_string_literal: true

module Leftovers
  module MatcherBuilders
    module Unless
      def self.build(matcher)
        Matchers::Not.new(matcher) if matcher
      end
    end
  end
end

# frozen_string_literal: true

module Leftovers
  module MatcherBuilders
    module Unless
      def self.build(matcher)
        return unless matcher

        ::Leftovers::Matchers::Not.new(matcher)
      end
    end
  end
end

# frozen_string_literal: true

require_relative '../matchers/not'

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

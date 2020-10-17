# frozen_string_literal: true

module Leftovers
  module MatcherBuilders
    module String
      def self.build(pattern)
        pattern.split(/\s+/).map(&:to_sym).to_set
      end
    end
  end
end

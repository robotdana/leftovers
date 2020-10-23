# frozen_string_literal: true

module Leftovers
  module MatcherBuilders
    module String
      def self.build(pattern)
        pattern.to_sym
      end
    end
  end
end

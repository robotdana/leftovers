# frozen_string_literal: true

module Leftovers
  module MatcherBuilders
    module And
      def self.build(matchers)
        matchers = matchers.compact
        case matchers.length
        # :nocov:
        when 0 then nil
        # :nocov:
        when 1 then matchers.first
        when 2 then ::Leftovers::Matchers::And.new(matchers.first, matchers[1])
        else ::Leftovers::Matchers::All.new(matchers.dup)
        end
      end
    end
  end
end

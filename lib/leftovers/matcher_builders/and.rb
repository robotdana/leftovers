# frozen_string_literal: true

module Leftovers
  module MatcherBuilders
    module And
      def self.build(matchers, compact: true) # rubocop:disable Metrics/MethodLength
        matchers.compact! if compact
        case matchers.length
        # :nocov:
        when 0 then raise
        # :nocov:
        when 1 then matchers.first
        when 2 then ::Leftovers::Matchers::And.new(matchers.first, matchers[1])
        else
          # turn two matchers at the end into 1
          # using pop because i want this to be progressively more nested
          # rather than progressively less nested
          last = matchers.pop
          next_last = matchers.pop
          matchers << ::Leftovers::Matchers::And.new(next_last, last)
          # recurse
          ::Leftovers::MatcherBuilders::And.build(matchers, compact: false)
        end
      end
    end
  end
end

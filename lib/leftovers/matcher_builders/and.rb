# frozen_string_literal: true

require_relative '../matchers/and'

module Leftovers
  module MatcherBuilders
    module And
      def self.each_or_self(value, &block)
        case value
        when Array then build(value.map(&block))
        else build([yield(value)])
        end
      end

      def self.build(matchers, compact: true) # rubocop:disable Metrics/MethodLength
        matchers = matchers.compact if compact
        case matchers.length
        when 0 then nil
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

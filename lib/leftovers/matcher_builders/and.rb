# frozen_string_literal: true

require_relative 'fallback'

require_relative '../matchers/and'

module Leftovers
  module MatcherBuilders
    module And
      def self.each_or_self(value, default, &block)
        case value
        when nil then ::Leftovers::MatcherBuilders::Fallback.build(default)
        when Array then build(value.map(&block), default)
        else build([yield(value)], default)
        end
      end

      def self.build(matchers, default = true) # rubocop:disable Metrics/MethodLength
        matchers = matchers.compact
        case matchers.length
        when 0 then ::Leftovers::MatcherBuilders::Fallback.build(default)
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
          ::Leftovers::MatcherBuilders::And.build(matchers, default, false)
        end
      end
    end
  end
end

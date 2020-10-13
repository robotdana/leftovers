# frozen_string_literal: true

require_relative 'fallback'
require_relative '../matchers/or'

require 'set'

module Leftovers
  module MatcherBuilders
    module Or
      def self.each_or_self(value, default, &block)
        case value
        when nil then ::Leftovers::MatcherBuilders::Fallback.build(default)
        when Array then build(value.map(&block), default)
        else build([yield(value)], default)
        end
      end

      def self.build(matchers, default = true, compact = true) # rubocop:disable Metrics/MethodLength
        matchers = compact(matchers) if compact

        case matchers.length
        when 0 then ::Leftovers::MatcherBuilders::Fallback.build(default)
        when 1 then matchers.first
        when 2 then ::Leftovers::Matchers::Or.new(matchers.first, matchers[1])
        else
          # turn two matchers at the end into 1
          # using pop because i want this to be progressively more nested
          # rather than progressively less nested
          last = matchers.pop
          next_last = matchers.pop
          matchers << ::Leftovers::Matchers::Or.new(next_last, last)
          # recurse
          ::Leftovers::MatcherBuilders::Or.build(matchers, default, false)
        end
      end

      def self.compact(matchers) # rubocop:disable Metrics/PerceivedComplexity, Metrics/MethodLength, Metrics/CyclomaticComplexity, Metrics/AbcSize,
        return matchers if matchers.length <= 1

        set = Set.new
        regexps = []
        uncompactable = []

        matchers.flatten!
        matchers.compact!

        if matchers.include?(::Leftovers::Matchers::Anything)
          return [::Leftovers::Matchers::Anything]
        end

        matchers.each do |matcher|
          next if matcher == ::Leftovers::Matchers::Nothing

          klass = matcher.class
          if klass == ::Set
            set.merge(matcher)
          elsif klass == ::Integer || klass == ::Symbol
            set << matcher
          elsif klass == ::Regexp
            regexps << matcher
          else
            uncompactable << matcher
          end
        end

        set = set.first if set.length <= 1
        regexps = if regexps.length <= 1
          regexps.first
        else
          Regexp.union(regexps)
        end

        [set, regexps].compact.concat(uncompactable)
      end
    end
  end
end

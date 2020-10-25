# frozen_string_literal: true

require 'set'

module Leftovers
  module MatcherBuilders
    module Or
      def self.each_or_self(value, &block)
        case value
        when nil then nil
        when Array then build(value.map(&block))
        else build([yield(value)])
        end
      end

      def self.build(matchers, compact: true) # rubocop:disable Metrics/MethodLength
        matchers = compact(matchers) if compact

        case matchers.length
          # :nocov:
        when 0 then raise
          # :nocov:
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
          ::Leftovers::MatcherBuilders::Or.build(matchers, compact: false)
        end
      end

      def self.flatten(value)
        case value
        when ::Leftovers::Matchers::Or
          [*flatten(value.lhs), *flatten(value.rhs)]
        when Array
          ret = value.map { |v| flatten(v) }
          ret.flatten!(1)
          ret
        else
          value
        end
      end

      def self.compact(matchers) # rubocop:disable Metrics/MethodLength, Metrics/CyclomaticComplexity, Metrics/AbcSize,
        return matchers if matchers.length <= 1

        set = Set.new
        regexps = []
        uncompactable = []

        matchers = flatten(matchers)

        matchers.each do |matcher|
          case matcher
          when nil then nil
          when ::Integer, ::Symbol then set << matcher
          # when ::Set then set.merge(matcher) # may not be necessary
          when ::Regexp then regexps << matcher
          else uncompactable << matcher
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

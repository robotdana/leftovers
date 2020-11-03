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

      def self.build(matchers)
        matchers = compact(matchers)
        case matchers.length
          # :nocov:
        when 0 then nil
          # :nocov:
        when 1 then matchers.first
        when 2 then ::Leftovers::Matchers::Or.new(matchers.first, matchers[1])
        else ::Leftovers::Matchers::Any.new(matchers.dup)
        end
      end

      def self.flatten(value) # rubocop:disable Metrics/MethodLength
        case value
        when ::Leftovers::Matchers::Or
          [*flatten(value.lhs), *flatten(value.rhs)]
        when ::Leftovers::Matchers::Any
          flatten(value.matchers)
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

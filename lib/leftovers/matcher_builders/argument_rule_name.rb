# frozen_string_literal: true

require_relative '../matchers/nothing'
require_relative '../matchers/anything'
require_relative '../matchers/and'
require_relative 'or'
require_relative 'and'

module Leftovers
  module MatcherBuilders
    module ArgumentRuleName
      def self.build(patterns, default: nil) # rubocop:disable Metrics/MethodLength, Metrics/CyclomaticComplexity, Metrics/PerceivedComplexity, Metrics/AbcSize
        or_matchers = []
        ::Leftovers.each_or_self(patterns) do |pat|
          # can't have these as part of the case statement because case equality
          next if pat == ::Leftovers::Matchers::Anything
          next if pat == ::Leftovers::Matchers::Nothing

          or_matchers << case pat
          when nil
            nil # do nothing
          when ::String
            pat.split(/\s+/).map(&:to_sym).to_set
          when ::Symbol, ::Integer, ::Set, ::Regexp, ::Leftovers::Matchers::Or
            pat
          when ::Hash
            build_from_hash(**pat)
          else
            raise ::Leftovers::ConfigError, "Invalid value #{pat.inspect} for name"
          end
        end
        or_matchers.compact!
        if or_matchers.empty?
          case default
          when true then ::Leftovers::Matchers::Anything
          when false then ::Leftovers::Matchers::Nothing
          when nil then nil
          else raise ArgumentError, 'Fallback must be true, false, or nil'
          end
        else
          ::Leftovers::MatcherBuilders::Or.build(or_matchers)
        end
      end

      def self.build_from_hash(match: nil, has_prefix: nil, has_suffix: nil, unless_arg: nil) # rubocop:disable Metrics/MethodLength
        re = if match
          /\A#{match}\z/
        elsif has_prefix && has_suffix
          /\A#{::Regexp.escape(has_prefix)}.*#{::Regexp.escape(has_suffix)}\z/x
        elsif has_prefix
          /\A#{::Regexp.escape(has_prefix)}/
        elsif has_suffix
          /#{::Regexp.escape(has_suffix)}\z/
        end

        return re unless unless_arg

        ::Leftovers::MatcherBuilders::And.build([
          re,
          ::Leftovers::Matchers::Not.new(
            ::Leftovers::MatcherBuilders::ArgumentRuleName.build(unless_arg, default: nil)
          )
        ])
      end
    end
  end
end

# frozen_string_literal: true

require_relative '../matchers/nothing'
require_relative '../matchers/anything'
require_relative '../matchers/and'
require_relative 'or'
require_relative 'and'

module Leftovers
  module MatcherBuilders
    module Name
      def self.build(patterns, default = true) # rubocop:disable Metrics/PerceivedComplexity, Metrics/MethodLength, Metrics/CyclomaticComplexity, Metrics/AbcSize
        or_matchers = []
        ::Leftovers.each_or_self(patterns) do |pat| # rubocop:disable Metrics/BlockLength
          # can't have these as part of the case statement because case equality
          next if pat == ::Leftovers::Matchers::Anything
          next if pat == ::Leftovers::Matchers::Nothing

          case pat
          when nil
            nil # do nothing
          when ::String
            or_matchers.concat(pat.split(/\s+/).map(&:to_sym))
          when ::Symbol, ::Integer, ::Set, ::Regexp, ::Leftovers::Matchers::Or
            or_matchers << pat
          when ::Hash
            re = if pat[:match]
              /\A#{pat[:match]}\z/
            elsif pat[:matches]
              /\A#{pat[:matches]}\z/
            elsif pat[:has_prefix] && pat[:has_suffix]
              /\A#{::Regexp.escape(pat[:has_prefix])}.*#{::Regexp.escape(pat[:has_suffix])}\z/x
            elsif pat[:has_prefix]
              /\A#{::Regexp.escape(pat[:has_prefix])}/
            elsif pat[:has_suffix]
              /#{::Regexp.escape(pat[:has_suffix])}\z/
            else
              raise ::Leftovers::ConfigError, "Invalid value for name #{pat.inspect}, "\
                'valid keys are matches, has_prefix, has_suffix, unless'
            end

            or_matchers << if pat[:unless]
              ::Leftovers::MatcherBuilders::And.build([
                re,
                ::Leftovers::Matchers::Not.new(
                  ::Leftovers::MatcherBuilders::Name.build(pat[:unless])
                )
              ])
            else
              re
            end
          else
            raise ::Leftovers::ConfigError, "Invalid value type for name #{pat.inspect}, "\
              'valid types are a String, or an object with keys matches, has_prefix, has_suffix'
          end
        end

        ::Leftovers::MatcherBuilders::Or.build(or_matchers, default)
      end
    end
  end
end

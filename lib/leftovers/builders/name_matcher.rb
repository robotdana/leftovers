# frozen_string_literal: true

require 'set'
require_relative '../matchers/nothing'
require_relative '../matchers/anything'
require_relative '../matchers/symbol'
require_relative 'fallback_matcher'

module Leftovers
  module Builders
    module NameMatcher
      def self.build(patterns, default = true) # rubocop:disable Metrics/PerceivedComplexity, Metrics/MethodLength, Metrics/CyclomaticComplexity, Metrics/AbcSize
        regexps = []
        syms = Set.new

        ::Leftovers.each_or_self(patterns) do |pat| # rubocop:disable Metrics/BlockLength
          # can't have these as part of the case statement because case equality
          next if pat == ::Leftovers::Matchers::Anything
          next if pat == ::Leftovers::Matchers::Nothing

          case pat
          when nil
            nil # do nothing
          when ::Leftovers::Matchers::Symbol
            pat.syms.is_a?(Set) ? syms.merge(pat.syms) : syms << pat.syms
            regexps << pat.regexp
          when ::String
            syms.merge(pat.split(/\s+/).map(&:to_sym))
          when ::Symbol
            syms << pat
          when ::Integer
            syms << pat
          when ::Set
            syms.merge(pat)
          when ::Regexp
            regexps << pat
          when ::Hash
            if pat[:match]
              regexps << /\A#{pat[:match]}\z/
            elsif pat[:matches]
              regexps << /\A#{pat[:matches]}\z/
            elsif pat[:has_prefix] && pat[:has_suffix]
              regexps << /
                \A#{::Regexp.escape(pat[:has_prefix])}
                .*
                #{::Regexp.escape(pat[:has_suffix])}\z
              /x
            elsif pat[:has_prefix]
              regexps << /\A#{::Regexp.escape(pat[:has_prefix])}/
            elsif pat[:has_suffix]
              regexps << /#{::Regexp.escape(pat[:has_suffix])}\z/
            else
              raise ::Leftovers::ConfigError, "Invalid value for name #{pat.inspect}, "\
                'valid keys are matches, has_prefix, has_suffix'
            end
          else
            raise ::Leftovers::ConfigError, "Invalid value type for name #{pat.inspect}, "\
              'valid types are a String, or an object with keys matches, has_prefix, has_suffix'
          end
        end

        syms = syms.first if syms.length <= 1

        regexp = if regexps.empty?
          nil
        else
          ::Regexp.union(regexps).freeze
        end

        if syms && regexp
          ::Leftovers::Matchers::Symbol.new(syms, regexp)
        else
          syms || regexp || ::Leftovers::Builders::FallbackMatcher.build(default)
        end
      end
    end
  end
end

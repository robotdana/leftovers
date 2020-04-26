# frozen_string_literal: true

require 'set'
module Leftovers
  class NameRule
    # :nocov:
    using ::Leftovers::SetCaseEq if defined?(::Leftovers::SetCaseEq)
    # :nocov:

    module TrueReturner
      def self.===(_value)
        true
      end
    end

    module FalseReturner
      def self.===(_value)
        false
      end
    end

    attr_reader :syms, :regexp

    def self.wrap(patterns, default = true) # rubocop:disable Metrics/PerceivedComplexity, Metrics/MethodLength, Metrics/CyclomaticComplexity, Metrics/AbcSize
      regexps = []
      syms = Set.new

      Leftovers.each_or_self(patterns) do |pat| # rubocop:disable Metrics/BlockLength
        # can't have these as part of the case statement because case equality
        next if pat == Leftovers::NameRule::TrueReturner
        next if pat == Leftovers::NameRule::FalseReturner

        case pat
        when nil
          nil # do nothing
        when Leftovers::NameRule
          pat.syms.is_a?(Set) ? syms.merge(pat.syms) : syms << pat.syms
          regexps << pat.regexp
        when String
          syms.merge(pat.split(/\s+/).map(&:to_sym))
        when Symbol
          syms << pat
        when Integer
          syms << pat
        when Set
          syms.merge(pat)
        when Regexp
          regexps << pat
        when Hash
          if pat[:match]
            regexps << /\A#{pat[:match]}\z/
          elsif pat[:matches]
            regexps << /\A#{pat[:matches]}\z/
          elsif pat[:has_prefix] && pat[:has_suffix]
            regexps << /\A#{Regexp.escape(pat[:has_prefix])}.*#{Regexp.escape(pat[:has_suffix])}\z/
          elsif pat[:has_prefix]
            regexps << /\A#{Regexp.escape(pat[:has_prefix])}/
          elsif pat[:has_suffix]
            regexps << /#{Regexp.escape(pat[:has_suffix])}\z/
          else
            raise Leftovers::ConfigError, "Invalid value for name #{pat}, "\
              'valid keys are matches, has_prefix, has_suffix'
          end
        else
          raise Leftovers::ConfigError, "Invalid value type for name #{pat}, "\
            'valid types are a String, or an object with keys matches, has_prefix, has_suffix'
        end
      end

      syms = syms.first if syms.length <= 1

      regexp = if regexps.empty?
        nil
      else
        Regexp.union(regexps).freeze
      end

      if syms && regexp
        new(syms, regexp)
      else
        syms || regexp || (
          default ? ::Leftovers::NameRule::TrueReturner : ::Leftovers::NameRule::FalseReturner
        )
      end
    end

    def initialize(syms, regexp)
      @syms = syms
      @regexp = regexp

      freeze
    end

    def ===(sym)
      @syms === sym || @regexp === sym
    end
  end
end

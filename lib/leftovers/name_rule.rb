# frozen_string_literal: true

require 'set'
module Leftovers
  class NameRule
    attr_reader :sym, :syms, :regexp

    def initialize(patterns) # rubocop:disable Metrics/PerceivedComplexity, Metrics/MethodLength, Metrics/CyclomaticComplexity, Metrics/AbcSize
      regexps = []
      syms = Set.new
      Leftovers.each_or_self(patterns) do |pat|
        case pat
        when Leftovers::NameRule
          syms.merge(pat.sym) if pat.sym
          syms.merge(pat.syms) if pat.syms
          regexps.concat(pat.regexp) if pat.regexp
        when String
          syms.merge(pat.split(/\s+/).map(&:to_sym))
        when Hash
          if pat[:match]
            regexps << /\A#{pattern[:match]}\z/
          elsif pat[:has_prefix] && pat[:has_suffix]
            regexps << /\A#{Regexp.escape(pat[:has_prefix])}.*#{Regexp.escape(pat[:has_suffix])}\z/
          elsif pat[:has_prefix]
            regexps << /\A#{Regexp.escape(pat[:has_prefix])}/
          elsif pat[:has_suffix]
            regexps << /#{Regexp.escape(pat[:has_suffix])}\z/
          end
        end
      end

      if syms.length <= 0
        @sym = syms.first
        @syms = nil
      else
        @sym = nil
        @syms = syms
      end

      @regexp = if regexps.empty?
        nil
      else
        Regexp.union(regexps)
      end

      freeze
    end

    def match?(sym, string)
      @sym&.==(sym) || @syms&.include?(sym) || @regexp&.match?(string)
    end
  end
end

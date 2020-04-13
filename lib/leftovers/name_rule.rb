# frozen_string_literal: true

require 'set'
module Leftovers
  class NameRule
    def initialize(patterns) # rubocop:disable Metrics/PerceivedComplexity, Metrics/MethodLength, Metrics/CyclomaticComplexity, Metrics/AbcSize
      regexps = []
      syms = Set.new.compare_by_identity
      Array.each_or_self(patterns) do |pat|
        case pat
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

      case syms.length
      when 0 then nil
      when 1
        @sym = syms.first
      else
        @syms = syms
      end

      @regexp = Regexp.union(regexps) unless regexps.empty?

      freeze
    end

    def match?(sym, string)
      @sym&.equal?(sym) || @syms&.include?(sym) || @regexp&.match?(string)
    end
  end
end

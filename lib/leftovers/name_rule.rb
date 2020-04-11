# frozen_string_literal: true

require 'set'
module Leftovers
  class NameRule
    def initialize(patterns) # rubocop:disable Metrics/PerceivedComplexity, Metrics/MethodLength, Metrics/CyclomaticComplexity, Metrics/AbcSize
      patterns = Leftovers.wrap_array(patterns)
      regexps = []
      strings = Set.new
      patterns.each do |pat|
        case pat
        when String
          strings.merge(pat.split(/\s+/).map(&:freeze))
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

      if strings.length <= 1
        @string = strings.first
      else
        @strings = strings
      end

      @regexp = Regexp.union(regexps) unless regexps.empty?
    end

    def match?(string)
      @string&.==(string) || @strings&.include?(string) || @regexp&.match?(string)
    end
  end
end

require 'set'
module Leftovers
  class NameRule
    def initialize(patterns)
      patterns = Leftovers.wrap_array(patterns)
      regexps = []
      strings = Set.new
      patterns.each do |pattern|
        case pattern
        when String
          strings.merge(pattern.split(/\s+/).map(&:freeze))
        when Hash
          if pattern[:match]
            regexps << /\A#{pattern[:match]}\z/
          elsif pattern[:has_prefix] && pattern[:has_suffix]
            regexps << /\A#{Regexp.escape(pattern[:has_prefix])}.*#{Regexp.escape(pattern[:has_suffix])}\z/
          elsif pattern[:has_prefix]
            regexps << /\A#{Regexp.escape(pattern[:has_prefix])}/
          elsif pattern[:has_suffix]
            regexps << /#{Regexp.escape(pattern[:has_suffix])}\z/
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

require 'set'
module Leftovers
  class NameRule
    def initialize(patterns)
      patterns = Leftovers.wrap_array(patterns)
      regexps = []
      @strings = Set.new
      patterns.each do |pattern|
        case pattern
        when String
          @strings.merge(pattern.split(/\s+/).map(&:freeze))
        when Hash
          if pattern[:match]
            regexps << /\A#{pattern[:match]}\z/
          elsif pattern[:prefix] && pattern[:suffix]
            regexps << /\A#{Regexp.escape(pattern[:prefix])}.*#{Regexp.escape(pattern[:suffix])}\z/
          elsif pattern[:prefix]
            regexps << /\A#{Regexp.escape(pattern[:prefix])}/
          elsif pattern[:suffix]
            regexps << /#{Regexp.escape(pattern[:suffix])}\z/
          end
        end
      end

      if @strings.length <= 1
        @string = @strings.first
        @strings = nil
      end

      @regexp = Regexp.union(regexps)
    end

    def match?(string)
      @string&.==(string) || @strings&.include?(string) || @regexp&.match?(string)
    end
  end
end

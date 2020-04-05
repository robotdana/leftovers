require 'set'
class Matcher
  def initialize(patterns)
    patterns = Forgotten.wrap_array(patterns)
    @strings = patterns.select { |pattern| pattern.is_a?(String) }.to_set
    regexps = patterns.select { |pattern| pattern.is_a?(Hash) }
    unless regexps.empty?
      regexps.map! do |pattern|
        if pattern[:match]
          /\A#{pattern[:match]}\z/
        elsif pattern[:prefix] && pattern[:suffix]
          /\A#{Regexp.escape(pattern[:prefix])}.*#{Regexp.escape(pattern[:suffix])}\z/
        elsif pattern[:prefix]
          /\A#{Regexp.escape(pattern[:prefix])}/
        elsif pattern[:suffix]
          /#{Regexp.escape(pattern[:suffix])}\z/
        end
      end
      @regexp = Regexp.union(regexps)
    end
  end

  def match?(string)
    @strings.include?(string) || @regexp&.match?(string)
  end
end

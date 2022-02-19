# frozen_string_literal: true

module Leftovers
  class ConfigLoader
    class Suggester
      def initialize(words)
        @words = words
        @did_you_mean = ::DidYouMean::SpellChecker.new(dictionary: words) if defined?(::DidYouMean)
      end

      def suggest(word)
        suggestions = did_you_mean.correct(word) if did_you_mean
        suggestions = words if !suggestions || suggestions.empty?
        suggestions
      end

      private

      attr_reader :words, :did_you_mean
    end
  end
end

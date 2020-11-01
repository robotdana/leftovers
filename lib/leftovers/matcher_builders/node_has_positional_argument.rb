# frozen-string-literal: true

module Leftovers
  module MatcherBuilders
    module NodeHasPositionalArgument
      def self.build(positions, value_matcher) # rubocop:disable Metrics/MethodLength
        if positions && value_matcher
          ::Leftovers::MatcherBuilders::Or.each_or_self(positions) do |position|
            ::Leftovers::Matchers::NodeHasPositionalArgumentWithValue.new(position, value_matcher)
          end
        elsif positions
          position = positions.is_a?(Array) ? positions.min : positions

          ::Leftovers::Matchers::NodeHasPositionalArgument.new(position)
        elsif value_matcher
          ::Leftovers::Matchers::NodeHasAnyPositionalArgumentWithValue.new(value_matcher)
        # :nocov:
        else raise
          # :nocov:
        end
      end
    end
  end
end

# frozen-string-literal: true

module Leftovers
  module MatcherBuilders
    module NodeHasPositionalArgument
      class << self
        def build(positions, value_matcher) # rubocop:disable Metrics/PerceivedComplexity, Metrics/CyclomaticComplexity, Metrics/MethodLength
          if positions && value_matcher
            ::Leftovers::MatcherBuilders::Or.each_or_self(positions) do |pos|
              if pos == '*'
                ::Leftovers::Matchers::NodeHasAnyPositionalArgumentWithValue.new(value_matcher)
              else
                ::Leftovers::Matchers::NodeHasPositionalArgumentWithValue.new(pos, value_matcher)
              end
            end
          elsif positions
            pos = 0 if ::Leftovers.each_or_self(positions).include?('*')
            pos ||= ::Leftovers.each_or_self(positions).min

            ::Leftovers::Matchers::NodeHasPositionalArgument.new(pos)
          elsif value_matcher
            ::Leftovers::Matchers::NodeHasAnyPositionalArgumentWithValue.new(value_matcher)
          end
        end
      end
    end
  end
end

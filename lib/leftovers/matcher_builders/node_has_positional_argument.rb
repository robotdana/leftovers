# frozen-string-literal: true

module Leftovers
  module MatcherBuilders
    module NodeHasPositionalArgument
      class << self
        def build(positions, value_matcher)
          if positions && !all_positions?(positions) && value_matcher
            build_has_positional_value_matcher(positions, value_matcher)
          elsif positions && !value_matcher
            build_has_position_matcher(positions)
          elsif value_matcher
            build_has_any_positional_value_matcher(value_matcher)
          end
        end

        private

        def all_positions?(positions)
          ::Leftovers.each_or_self(positions).include?('*')
        end

        def build_has_position_matcher(positions)
          position = 0 if all_positions?(positions)
          position ||= ::Leftovers.each_or_self(positions).min

          ::Leftovers::Matchers::NodeHasPositionalArgument.new(position)
        end

        def build_has_any_positional_value_matcher(value_matcher)
          ::Leftovers::Matchers::NodeHasAnyPositionalArgumentWithValue.new(value_matcher)
        end

        def build_has_positional_value_matcher(positions, value_matcher)
          ::Leftovers::MatcherBuilders::Or.each_or_self(positions) do |position|
            ::Leftovers::Matchers::NodeHasPositionalArgumentWithValue.new(position, value_matcher)
          end
        end
      end
    end
  end
end

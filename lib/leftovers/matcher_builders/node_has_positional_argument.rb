# frozen_string_literal: true

module Leftovers
  module MatcherBuilders
    module NodeHasPositionalArgument
      class << self
        def build(positions, value_matcher)
          positions = ::Leftovers.wrap_array(positions)
          if !positions.empty? && !all_positions?(positions) && value_matcher
            build_has_positional_value_matcher(positions, value_matcher)
          elsif !positions.empty? && !value_matcher
            build_has_position_matcher(positions)
          elsif value_matcher
            build_has_any_positional_value_matcher(value_matcher)
          end
        end

        private

        def all_positions?(positions)
          positions.include?('*')
        end

        def build_has_position_matcher(positions)
          last_position = all_positions?(positions) ? 0 : positions.min

          Matchers::NodeHasPositionalArgument.new(last_position)
        end

        def build_has_any_positional_value_matcher(value_matcher)
          Matchers::NodeHasAnyPositionalArgumentWithValue.new(value_matcher)
        end

        def build_has_positional_value_matcher(positions, value_matcher)
          Or.each_or_self(positions) do |position|
            Matchers::NodeHasPositionalArgumentWithValue.new(position, value_matcher)
          end
        end
      end
    end
  end
end

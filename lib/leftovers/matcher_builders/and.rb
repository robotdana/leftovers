# frozen_string_literal: true

module Leftovers
  module MatcherBuilders
    module And
      class << self
        def build(matchers)
          matchers = flatten(matchers).compact
          case matchers.length
          # :nocov:
          when 0 then nil
          # :nocov:
          when 1 then matchers.first
          when 2 then ::Leftovers::Matchers::And.new(matchers.first, matchers[1])
          else ::Leftovers::Matchers::All.new(matchers.dup)
          end
        end

        private

        def flatten(value)
          case value
          when ::Leftovers::Matchers::And
            [*flatten(value.lhs), *flatten(value.rhs)]
          # :nocov: # not sure how to make this happen
          when ::Leftovers::Matchers::All
            flatten(value.matchers)
          # :nocov:
          when Array
            value.flat_map { |v| flatten(v) }
          else
            [value]
          end
        end
      end
    end
  end
end

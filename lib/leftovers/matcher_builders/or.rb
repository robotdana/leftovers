# frozen_string_literal: true

require 'set'

module Leftovers
  module MatcherBuilders
    module Or
      class << self
        def each_or_self(value, &block)
          case value
          when nil then nil
          when Array then build(value.map(&block))
          else build([yield(value)])
          end
        end

        def build(matchers)
          matchers = compact(matchers)
          case matchers.length
            # :nocov:
          when 0 then nil
            # :nocov:
          when 1 then matchers.first
          when 2 then ::Leftovers::Matchers::Or.new(matchers.first, matchers[1])
          else ::Leftovers::Matchers::Any.new(matchers.dup)
          end
        end

        private

        def flatten(value)
          case value
          when ::Leftovers::Matchers::Or
            [*flatten(value.lhs), *flatten(value.rhs)]
          when ::Leftovers::Matchers::Any
            flatten(value.matchers)
          when Array
            value.flat_map { |v| flatten(v) }
          else
            value
          end
        end

        def group_by_compactable(matchers)
          groups = matchers.group_by do |matcher|
            case matcher
            when ::Integer, ::Symbol then :set
            when ::Regexp then :regexp
            else :uncompactable
            end
          end

          groups.transform_values { |v| Leftovers.unwrap_array(v) }
        end

        def build_grouped(set: nil, regexp: nil, uncompactable: nil)
          set = set.to_set if set.is_a?(Array)
          regexp = Regexp.union(regexp) if regexp.is_a?(Array)

          [set, regexp].concat(Array(uncompactable)).compact
        end

        def compact(matchers)
          matchers = flatten(matchers)

          return matchers if matchers.length <= 1

          build_grouped(**group_by_compactable(matchers))
        end
      end
    end
  end
end

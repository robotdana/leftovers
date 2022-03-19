# frozen_string_literal: true

require 'set'

module Leftovers
  module MatcherBuilders
    module Or
      class << self
        def each_or_self(value, &block)
          case value
          when nil then nil
          when ::Array then build(value.map(&block))
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
          when 2 then Matchers::Or.new(matchers.first, matchers[1])
          else Matchers::Any.new(matchers.dup)
          end
        end

        private

        def flatten(value)
          case value
          when Matchers::Or
            [*flatten(value.lhs), *flatten(value.rhs)]
          when Matchers::Any
            flatten(value.matchers)
          when ::Array, ::Set
            value.flat_map { |v| flatten(v) }
          else
            [value]
          end
        end

        def group_by_compactable(matchers)
          groups = matchers.group_by do |matcher|
            case matcher
            when ::Integer, ::Symbol, true, false then :set
            when ::Regexp then :regexp
            when nil then :nil
            else matcher.class.to_s.to_sym
            end
          end

          groups.transform_values { |v| ::Leftovers.unwrap_array(v) }
        end

        def mergeable?(matcher)
          matcher.respond_to?(:matcher)
        end

        def build_grouped_for_matcher(matchers)
          return matchers unless matchers.is_a?(::Array)
          return matchers unless mergeable?(matchers.first)

          matchers.first.class.new(build(matchers.map(&:matcher)))
        end

        def build_grouped(set: nil, regexp: nil, nil: nil, **matcher_classes) # rubocop:disable Lint/UnusedMethodArgument i want to throw away nils
          set = set.to_set.compare_by_identity if set.is_a?(::Array)
          regexp = ::Regexp.union(regexp) if regexp.is_a?(::Array)
          matcher_classes = matcher_classes.each_value.flat_map do |matchers|
            build_grouped_for_matcher(matchers)
          end

          [set, regexp].compact.concat(matcher_classes).uniq
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

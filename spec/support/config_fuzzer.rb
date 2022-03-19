# frozen_string_literal: true

require 'yaml'

module Leftovers
  class ConfigLoader
    class Fuzzer # rubocop:disable Metrics/ClassLength
      def initialize(iteration)
        srand ::RSpec.configuration.seed + iteration
      end

      def to_yaml
        fuzz_object(DocumentSchema).to_yaml
      end

      private

      def fuzz(schema, nesting = 0) # rubocop:disable Metrics
        case schema
        when ValueOrArraySchema then fuzz_value_or_array(schema, nesting)
        when ArraySchema then fuzz_array(schema, nesting)
        when ValueOrObjectSchema then fuzz_value_or_object(schema, nesting)
        when ObjectSchema then fuzz_object(schema, nesting)
        when StringEnumSchema then fuzz_string_enum(schema)
        when RegexpSchema then fuzz_regexp
        when StringSchema then fuzz_string
        when ScalarValueSchema then fuzz_scalar
        when TrueSchema then fuzz_true
        when ScalarArgumentSchema then fuzz_string_or_integer
        else raise UnexpectedCase, "Unhandled value #{schema.inspect}"
        end
      end

      def selectable_attributes(attributes, nesting = 0)
        return attributes unless weighted_rand(nesting)

        attributes.reject { |a| a.schema.instance_of?(ArraySchema) }
      end

      def sample_object_attributes(schema, nesting = 0)
        schema_attributes = selectable_attributes(schema.attributes, nesting)
        attributes = schema_attributes.sample(rand(schema_attributes.length))
        attributes += schema.require_groups.flat_map do |attrs|
          selectable_attributes(attrs, nesting).sample
        end

        attributes.uniq.shuffle
      end

      def fuzz_value_or_object(schema, nesting = 0)
        return fuzz_object(schema, nesting) unless weighted_rand(nesting)

        fuzz(schema.or_value_schema, nesting + 1)
      end

      def fuzz_object(schema, nesting = 0)
        sample_object_attributes(schema, nesting).map do |attr|
          [[*attr.aliases, attr.name].sample.to_s, fuzz(attr.schema, nesting + 1)]
        end.to_h
      end

      def fuzz_array(schema, nesting = 0)
        ::Array.new(rand(1..3)) { fuzz(schema.value_schema, nesting + 1) }
      end

      def fuzz_value_or_array(schema, nesting = 0)
        return fuzz_array(schema, nesting) unless weighted_rand(nesting)

        fuzz(schema.value_schema, nesting + 1)
      end

      def fuzz_string_enum(schema)
        schema.values.concat(schema.aliases.keys).sample.to_s
      end

      def fuzz_integer
        low_rand(999_999_999_999) * [-1, 0, +1].sample
      end

      def fuzz_float
        fuzz_integer + rand
      end

      def fuzz_string
        return fuzz_meaningful_string if rand(2) == 0

        ::Array.new(low_rand(1000)) { fuzz_character }.join
      end

      def fuzz_meaningful_string
        ['', '*', '**', '+', "#{rand(100)}+"].sample
      end

      def fuzz_regexp_candidate
        ::Array.new(low_rand(100)) do
          ['^$*+?[]{}()\\.,-!=<>'.chars.sample, fuzz_character].sample
        end.join
      end

      def fuzz_regexp(tries = 0)
        return '.*' if tries >= 20

        begin
          /#{fuzz_regexp_candidate}/.source
        rescue ::RegexpError, ::ArgumentError
          fuzz_regexp(tries + 1)
        end
      end

      def low_rand(max)
        m = Math.sqrt(max).to_i
        rand(m) * rand(m)
      end

      # more likely as we nest
      def weighted_rand(weight)
        return rand(2) == 0 if weight <= 1 # 1/2
        return rand(weight) < weight - 2 if weight <= 10 # linear
        return rand(weight * weight) < (weight * weight) - 2 if weight <= 20

        true # never
      end

      def fuzz_character(max = 0x100)
        low_rand(max).chr('UTF-8').match(/[[:alpha:]]/)&.[](0) || ''
      end

      def fuzz_true
        [true, 'true'].sample
      end

      def fuzz_string_or_integer
        [method(:fuzz_integer), method(:fuzz_string)].sample.call
      end

      def fuzz_scalar
        case rand(6)
        when 0 then fuzz_integer
        when 1 then fuzz_float
        when 2 then fuzz_string
        when 3 then true
        when 4 then false
        when 5 then nil
        end
      end
    end
  end
end

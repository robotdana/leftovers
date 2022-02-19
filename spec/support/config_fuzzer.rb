# frozen_string_literal: true

require 'yaml'

class ConfigFuzzer # rubocop:disable Metrics/ClassLength
  def initialize(iteration)
    srand RSpec.configuration.seed + iteration
  end

  def to_yaml
    fuzz_object(Leftovers::ConfigLoader::DocumentSchema).to_yaml
  end

  def fuzz(schema, nesting: 0) # rubocop:disable Metrics/PerceivedComplexity, Metrics/MethodLength, Metrics/CyclomaticComplexity
    if schema.is_a?(Leftovers::ConfigLoader::ValueOrArraySchema)
      fuzz_value_or_array(schema, nesting: nesting)
    elsif schema < Leftovers::ConfigLoader::ObjectSchema
      fuzz_object(schema, nesting: nesting)
    elsif schema < Leftovers::ConfigLoader::StringEnumSchema
      fuzz_string_enum(schema)
    elsif schema == Leftovers::ConfigLoader::StringSchema
      fuzz_string
    elsif schema == Leftovers::ConfigLoader::ScalarValueSchema
      fuzz_scalar
    elsif schema == Leftovers::ConfigLoader::TrueSchema
      fuzz_true
    elsif schema == Leftovers::ConfigLoader::ScalarArgumentSchema
      fuzz_string_or_integer
    else
      raise "Unfuzzable schema #{schema}"
    end
  end

  def sample_required_object_keys(schema)
    schema.require_groups.each_value.flat_map do |keys|
      keys -= schema.aliases.keys
      length = low_rand(keys.length) + 1
      keys.sample(length)
    end
  end

  def sample_object_attributes(schema)
    length = rand(schema.attributes.keys.length + 1)
    sample_keys = schema.attributes.keys.sample(length)
    sample_keys += sample_required_object_keys(schema)
    sample_keys.uniq!
    sample_keys.shuffle!

    schema.attributes.slice(*sample_keys)
  end

  def sample_alias(schema, key)
    [*schema.aliases.select { |_k, v| v == key }.keys, key].sample
  end

  def fuzz_object(schema, nesting: 0)
    if schema.or_schema && (rand(2) == 0 || nesting > 3)
      fuzz(schema.or_schema, nesting: nesting + 1)
    else
      sample_object_attributes(schema).map do |attribute, value_schema|
        [sample_alias(schema, attribute).to_s, fuzz(value_schema, nesting: nesting + 1)]
      end.to_h
    end
  end

  def fuzz_array(schema, nesting: 0)
    Array.new(rand(1..2)) { fuzz(schema.value_schema, nesting: nesting + 1) }
  end

  def fuzz_value_or_array(schema, nesting: 0)
    if rand(2) == 0 || nesting > 3
      fuzz(schema.value_schema, nesting: nesting + 1)
    else
      fuzz_array(schema, nesting: nesting + 1)
    end
  end

  def fuzz_string_enum(schema)
    sample_alias(schema, schema.values.sample).to_s
  end

  def fuzz_integer
    low_rand(999_999_999_999) * [-1, 0, +1].sample
  end

  def fuzz_float
    fuzz_integer + rand
  end

  def fuzz_string
    case rand(5)
    when 0
      ''
    else
      Array.new(low_rand(1000)) { fuzz_character }.join
    end
  end

  def low_rand(max)
    m = Math.sqrt(max).to_i
    rand(m) * rand(m)
  end

  def fuzz_character(max = 0x100)
    low_rand(max).chr('UTF-8').match(/[[:alpha:]]/)&.[](0) || ''
  end

  def fuzz_true
    [true, 'true'].sample
  end

  def fuzz_string_or_integer
    case rand(2)
    when 0
      fuzz_integer
    else
      fuzz_string
    end
  end

  def fuzz_scalar
    case rand(4)
    when 0
      [true, false, nil].sample
    when 1
      fuzz_integer
    when 2
      fuzz_string
    when 3
      fuzz_float
    end
  end
end

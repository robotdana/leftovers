# frozen_string_literal: true

require 'yaml'

class ConfigFuzzer
  def initialize(iteration)
    srand RSpec.configuration.seed + iteration
  end

  def to_yaml
    fuzz_object(Leftovers::ConfigLoader::DocumentSchema).to_yaml
  end

  private

  def fuzz(schema, nesting: 0) # rubocop:disable Metrics
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
      raise Leftovers::UnexpectedCase, "Unhandled value #{schema.inspect}"
    end
  end

  def sample_object_attributes(schema)
    length = rand(schema.attributes.length + 1)
    attributes = schema.attributes.sample(length)
    attributes += schema.require_groups.flat_map(&:sample)
    attributes.uniq.shuffle
  end

  def fuzz_object(schema, nesting: 0)
    if schema.or_schema && (rand(2) == 0 || nesting > 3)
      fuzz(schema.or_schema, nesting: nesting + 1)
    else
      sample_object_attributes(schema).map do |attr|
        [[*attr.aliases, attr.name].sample.to_s, fuzz(attr.schema, nesting: nesting + 1)]
      end.to_h
    end
  end

  def fuzz_value_or_array(schema, nesting: 0)
    if rand(2) == 0 || nesting > 3
      fuzz(schema.value_schema, nesting: nesting + 1)
    else
      Array.new(rand(1..2)) { fuzz(schema.value_schema, nesting: nesting + 1) }
    end
  end

  def fuzz_string_enum(schema)
    key = schema.values.sample
    [*schema.aliases.each_key.select { |aka| aka == key }, key].sample.to_s
  end

  def fuzz_integer
    low_rand(999_999_999_999) * [-1, 0, +1].sample
  end

  def fuzz_float
    fuzz_integer + rand
  end

  def fuzz_string
    if rand(5) == 0
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
    when 0 then fuzz_integer
    else fuzz_string
    end
  end

  def fuzz_scalar
    case rand(6)
    when 0 then true
    when 1 then false
    when 2 then fuzz_integer
    when 3 then fuzz_string
    when 4 then fuzz_float
    else nil
    end
  end
end

# frozen_string_literal: true

module Leftovers
  class ConfigLoader
    class ValueMatcherSchema < ValueOrObjectSchema
      attribute :arguments, ValueOrArraySchema[ArgumentPositionSchema], aliases: :argument,
        require_group: :matcher
      attribute :keywords, ValueOrArraySchema[StringPatternSchema], aliases: :keyword,
        require_group: :matcher
      attribute :itself, TrueSchema, require_group: :matcher
      attribute :nested, ValueOrArraySchema[ValueMatcherSchema]
      attribute :value, ValueOrArraySchema[StringSchema], require_group: :matcher, aliases: :values
      attribute :receiver, TrueSchema, require_group: :matcher
      attribute :recursive, TrueSchema

      inherit_attributes_from ValueMatcherConditionSchema

      self.or_value_schema = ScalarArgumentSchema
    end
  end
end

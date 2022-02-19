# frozen_string_literal: true

module Leftovers
  class ConfigLoader
    class ValueMatcherSchema < ObjectSchema
      attribute :arguments, ValueOrArraySchema[ArgumentPositionSchema], aliases: :argument,
        require_group: :matcher
      attribute :keywords, ValueOrArraySchema[StringPatternSchema], aliases: :keyword,
        require_group: :matcher
      attribute :itself, TrueSchema, require_group: :matcher
      attribute :nested, ValueOrArraySchema[ValueMatcherSchema], require_group: :matcher
      attribute :value, StringSchema, require_group: :matcher
      attribute :recursive, TrueSchema, require_group: :matcher

      self.or_schema = ScalarArgumentSchema
    end
  end
end

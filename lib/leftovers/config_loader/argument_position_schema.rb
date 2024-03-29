# frozen_string_literal: true

module Leftovers
  class ConfigLoader
    class ArgumentPositionSchema < ValueOrObjectSchema
      inherit_attributes_from StringPatternSchema, except: :unless
      attribute :type, ValueOrArraySchema[ValueTypeSchema], require_group: :matcher
      attribute :unless, ValueOrArraySchema[KeywordArgumentSchema], require_group: :matcher

      self.or_value_schema = ScalarArgumentSchema
    end
  end
end

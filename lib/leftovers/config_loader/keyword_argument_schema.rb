# frozen_string_literal: true

module Leftovers
  class ConfigLoader
    class KeywordArgumentSchema < ValueOrObjectSchema
      inherit_attributes_from StringPatternSchema, except: :unless
      attribute :type, ValueOrArraySchema[ValueTypeSchema], require_group: :matcher
      attribute :unless, ValueOrArraySchema[KeywordArgumentSchema], require_group: :matcher

      self.or_value_schema = StringSchema
    end
  end
end

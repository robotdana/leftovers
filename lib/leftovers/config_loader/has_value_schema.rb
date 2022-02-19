# frozen_string_literal: true

module Leftovers
  class ConfigLoader
    class HasValueSchema < ObjectSchema
      inherit_attributes_from StringPatternSchema

      attribute :at, ValueOrArraySchema[ArgumentPositionSchema], require_group: :matcher
      attribute :has_value, ValueOrArraySchema[HasValueSchema], require_group: :matcher

      attribute :has_receiver, ValueOrArraySchema[HasValueSchema], require_group: :matcher
      attribute :type, ValueOrArraySchema[ValueTypeSchema], require_group: :matcher
      attribute :unless, ValueOrArraySchema[HasValueSchema], require_group: :matcher

      self.or_schema = ScalarValueSchema
    end
  end
end

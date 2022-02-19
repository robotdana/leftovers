# frozen_string_literal: true

module Leftovers
  class ConfigLoader
    class HasArgumentSchema < ObjectSchema
      attribute :at, ValueOrArraySchema[ArgumentPositionSchema], require_group: :matcher
      attribute :has_value, ValueOrArraySchema[HasValueSchema], require_group: :matcher
      attribute :unless, ValueOrArraySchema[HasArgumentSchema], require_group: :matcher

      self.or_schema = ScalarArgumentSchema
    end
  end
end

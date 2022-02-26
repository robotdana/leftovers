# frozen_string_literal: true

module Leftovers
  class ConfigLoader
    class ArgumentPositionSchema < ValueOrObjectSchema
      inherit_attributes_from StringPatternSchema

      self.or_value_schema = ScalarArgumentSchema
    end
  end
end

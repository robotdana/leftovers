# frozen_string_literal: true

module Leftovers
  class ConfigLoader
    class ArgumentPositionSchema < ObjectSchema
      inherit_attributes_from StringPatternSchema

      self.or_schema = ScalarArgumentSchema
    end
  end
end

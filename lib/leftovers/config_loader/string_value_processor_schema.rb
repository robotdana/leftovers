# frozen_string_literal: true

module Leftovers
  class ConfigLoader
    class StringValueProcessorSchema < ValueOrObjectSchema
      inherit_attributes_from ValueProcessorSchema

      self.or_value_schema = StringSchema
    end
  end
end

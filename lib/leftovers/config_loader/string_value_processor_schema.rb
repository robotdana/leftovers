# frozen_string_literal: true

module Leftovers
  class ConfigLoader
    class StringValueProcessorSchema < ObjectSchema
      inherit_attributes_from ValueProcessorSchema

      self.or_schema = StringSchema
    end
  end
end

# frozen_string_literal: true

module Leftovers
  class ConfigLoader
    class ValueProcessorSchema < ObjectSchema
      inherit_attributes_from ValueMatcherSchema

      attribute :transforms, ValueOrArraySchema[TransformSchema]
      inherit_attributes_from TransformSchema, require_group: nil

      self.or_schema = ScalarArgumentSchema
    end
  end
end

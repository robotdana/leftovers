# frozen_string_literal: true

module Leftovers
  class ConfigLoader
    class ValueProcessorSchema < ValueOrObjectSchema
      inherit_attributes_from ValueMatcherSchema

      attribute :transforms, ValueOrArraySchema[TransformSchema], aliases: :transform
      inherit_attributes_from TransformSchema, require_group: nil, except: :transforms

      self.or_value_schema = ScalarArgumentSchema
    end
  end
end

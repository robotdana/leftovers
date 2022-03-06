# frozen_string_literal: true

module Leftovers
  class ConfigLoader
    class TransformSchema < ValueOrObjectSchema
      ArgumentlessTransformSchema.each_value do |transform|
        attribute(
          transform, TrueSchema,
          aliases: ArgumentlessTransformSchema.aliases_for(transform),
          require_group: :processor
        )
      end

      attribute(
        :add_prefix, ValueOrArraySchema[StringValueProcessorSchema], require_group: :processor
      )

      attribute(
        :add_suffix, ValueOrArraySchema[StringValueProcessorSchema], require_group: :processor
      )

      attribute :split, StringSchema, require_group: :processor
      attribute :delete_prefix, ValueOrArraySchema[StringSchema], require_group: :processor
      attribute :delete_suffix, ValueOrArraySchema[StringSchema], require_group: :processor
      attribute :delete_before, ValueOrArraySchema[StringSchema], require_group: :processor
      attribute :delete_before_last, ValueOrArraySchema[StringSchema], require_group: :processor
      attribute :delete_after, ValueOrArraySchema[StringSchema], require_group: :processor
      attribute :delete_after_last, ValueOrArraySchema[StringSchema], require_group: :processor
      attribute :transforms, ValueOrArraySchema[TransformSchema], require_group: :processor,
        aliases: :transform

      self.or_value_schema = ArgumentlessTransformSchema
    end
  end
end

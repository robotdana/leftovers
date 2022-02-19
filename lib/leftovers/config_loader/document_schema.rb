# frozen_string_literal: true

module Leftovers
  class ConfigLoader
    class DocumentSchema < ObjectSchema
      attribute :include_paths, ValueOrArraySchema[StringSchema], aliases: :include_path
      attribute :exclude_paths, ValueOrArraySchema[StringSchema], aliases: :exclude_path
      attribute :test_paths, ValueOrArraySchema[StringSchema], aliases: :test_path
      attribute :haml_paths, ValueOrArraySchema[StringSchema], aliases: :haml_path
      attribute :slim_paths, ValueOrArraySchema[StringSchema], aliases: :slim_path
      attribute :yaml_paths, ValueOrArraySchema[StringSchema], aliases: :yaml_path
      attribute :json_paths, ValueOrArraySchema[StringSchema], aliases: :json_path
      attribute :erb_paths, ValueOrArraySchema[StringSchema], aliases: :erb_path
      attribute :requires, ValueOrArraySchema[StringSchema], aliases: :require
      attribute :gems, ValueOrArraySchema[StringSchema], aliases: :gem
      attribute :keep, ValueOrArraySchema[KeepTestOnlySchema]
      attribute :test_only, ValueOrArraySchema[KeepTestOnlySchema]
      attribute :dynamic, ValueOrArraySchema[DynamicSchema]
    end
  end
end

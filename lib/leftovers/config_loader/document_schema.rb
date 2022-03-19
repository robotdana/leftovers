# frozen_string_literal: true

module Leftovers
  class ConfigLoader
    class DocumentSchema < ObjectSchema
      attribute :include_paths, ValueOrArraySchema[StringSchema], aliases: :include_path
      attribute :exclude_paths, ValueOrArraySchema[StringSchema], aliases: :exclude_path
      attribute :test_paths, ValueOrArraySchema[StringSchema], aliases: :test_path
      attribute :haml_paths, ValueOrArraySchema[StringSchema], aliases: :haml_path, suggest: false
      attribute :slim_paths, ValueOrArraySchema[StringSchema], aliases: :slim_path, suggest: false
      attribute :yaml_paths, ValueOrArraySchema[StringSchema], aliases: :yaml_path, suggest: false
      attribute :json_paths, ValueOrArraySchema[StringSchema], aliases: :json_path, suggest: false
      attribute :erb_paths, ValueOrArraySchema[StringSchema], aliases: :erb_path, suggest: false
      attribute :precompile, ValueOrArraySchema[PrecompileSchema]
      attribute :requires, ValueOrArraySchema[RequireSchema], aliases: :require
      attribute :gems, ValueOrArraySchema[StringSchema], aliases: :gem
      attribute :keep, ValueOrArraySchema[KeepTestOnlySchema]
      attribute :test_only, ValueOrArraySchema[KeepTestOnlySchema]
      attribute :dynamic, ValueOrArraySchema[DynamicSchema]

      PRECOMPILERS = %i{haml_paths slim_paths json_paths yaml_paths erb_paths}.freeze

      def self.to_ruby(node) # rubocop:disable Metrics
        read_hash = super
        write_hash = read_hash.dup

        read_hash.each do |key, value|
          next unless PRECOMPILERS.include?(key)

          value = { paths: value, format: key.to_s.delete_suffix('_paths').to_sym }
          yaml = { 'precompile' => [value.transform_keys(&:to_s).transform_values(&:to_s)] }
            .to_yaml.delete_prefix("---\n")

          ::Leftovers.warn(<<~MESSAGE)
            \e[33m`#{key}:` is deprecated\e[0m
            Replace with:
            \e[32m#{yaml}\e[0m
          MESSAGE

          write_hash[:precompile] = ::Leftovers.each_or_self(write_hash[:precompile]).to_a
          write_hash[:precompile] << value
          write_hash.delete(key)
        end

        write_hash
      end
    end
  end
end

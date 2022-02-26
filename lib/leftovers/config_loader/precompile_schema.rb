# frozen_string_literal: true

module Leftovers
  class ConfigLoader
    class PrecompileSchema < ObjectSchema
      attribute :paths, ValueOrArraySchema[StringSchema],
                aliases: %i{path include_paths include_path}, require_group: :paths

      attribute :format, PrecompilerSchema, require_group: :precompiler
    end
  end
end

# frozen_string_literal: true

module Leftovers
  class ConfigLoader
    class PrecompilerSchema < ValueOrObjectSchema
      attribute :custom, StringSchema, require_group: :custom

      self.or_value_schema = BuiltInPrecompilerSchema
    end
  end
end

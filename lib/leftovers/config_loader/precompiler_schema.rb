# frozen_string_literal: true

module Leftovers
  class ConfigLoader
    class PrecompilerSchema < ObjectSchema
      attribute :custom, StringSchema, require_group: :custom

      self.or_schema = BuiltInPrecompilerSchema
    end
  end
end

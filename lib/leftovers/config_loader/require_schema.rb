# frozen_string_literal: true

module Leftovers
  class ConfigLoader
    class RequireSchema < ValueOrObjectSchema
      attribute :quiet, StringSchema, require_group: :quiet

      self.or_value_schema = StringSchema
    end
  end
end

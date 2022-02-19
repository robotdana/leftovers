# frozen_string_literal: true

module Leftovers
  class ConfigLoader
    class RequireSchema < ObjectSchema
      attribute :quiet, StringSchema, aliases: :name, require_group: :quiet

      self.or_schema = StringSchema
    end
  end
end

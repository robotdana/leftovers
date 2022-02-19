# frozen_string_literal: true

module Leftovers
  class ConfigLoader
    class StringPatternSchema < ObjectSchema
      attribute :match, StringSchema, aliases: :matches, require_group: :matcher
      attribute :has_prefix, StringSchema, require_group: :matcher
      attribute :has_suffix, StringSchema, require_group: :matcher
      attribute :unless, ValueOrArraySchema[StringPatternSchema], require_group: :matcher

      self.or_schema = StringSchema
    end
  end
end

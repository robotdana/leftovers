# frozen_string_literal: true

module Leftovers
  class ConfigLoader
    class KeepTestOnlySchema < ObjectSchema
      inherit_attributes_from StringPatternSchema
      inherit_attributes_from RulePatternSchema

      self.or_schema = StringSchema
    end
  end
end

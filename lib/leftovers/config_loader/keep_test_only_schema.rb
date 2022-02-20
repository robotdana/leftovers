# frozen_string_literal: true

module Leftovers
  class ConfigLoader
    class KeepTestOnlySchema < ObjectSchema
      inherit_attributes_from StringPatternSchema, except: :unless
      inherit_attributes_from RulePatternSchema, except: :unless
      attribute :unless, ValueOrArraySchema[KeepTestOnlySchema], require_group: :matcher

      self.or_schema = StringSchema
    end
  end
end

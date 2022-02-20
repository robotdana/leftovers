# frozen_string_literal: true

module Leftovers
  class ConfigLoader
    class PrivacyProcessorSchema < ObjectSchema
      inherit_attributes_from ValueProcessorSchema
      attribute :to, PrivacySchema, require_group: :privacy_setting

      self.or_schema = nil
    end
  end
end

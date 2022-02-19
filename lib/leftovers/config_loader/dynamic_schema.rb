# frozen_string_literal: true

module Leftovers
  class ConfigLoader
    class DynamicSchema < ObjectSchema
      inherit_attributes_from RulePatternSchema

      attribute :call, ValueOrArraySchema[ValueProcessorSchema], aliases: :calls,
        require_group: :processor
      attribute :define, ValueOrArraySchema[ValueProcessorSchema], aliases: :defines,
        require_group: :processor
    end
  end
end

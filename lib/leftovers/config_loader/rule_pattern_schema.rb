# frozen_string_literal: true

module Leftovers
  class ConfigLoader
    class RulePatternSchema < ObjectSchema
      attribute :names, ValueOrArraySchema[StringPatternSchema], aliases: :name,
        require_group: :matcher
      attribute :paths, ValueOrArraySchema[StringSchema], aliases: :path, require_group: :matcher
      attribute :document, TrueSchema, require_group: :matcher
      attribute :has_arguments, ValueOrArraySchema[HasArgumentSchema], aliases: :has_argument,
        require_group: :matcher
      attribute :has_receiver, ValueOrArraySchema[HasValueSchema], require_group: :matcher
      attribute :unless, ValueOrArraySchema[RulePatternSchema], require_group: :matcher
    end
  end
end
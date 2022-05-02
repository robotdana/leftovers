# frozen_string_literal: true

module Leftovers
  class ConfigLoader
    class HasValueSchema < ValueOrObjectSchema
      attribute :names, ValueOrArraySchema[StringPatternSchema], aliases: :name,
        require_group: :matcher
      inherit_attributes_from StringPatternSchema, except: :unless
      attribute :has_arguments, ValueOrArraySchema[HasArgumentSchema], aliases: :has_argument,
        require_group: :matcher

      attribute :at, ValueOrArraySchema[ArgumentPositionSchema], require_group: :matcher
      attribute :has_value, ValueOrArraySchema[HasValueSchema], require_group: :matcher

      attribute :has_receiver, ValueOrArraySchema[HasReceiverSchema], require_group: :matcher
      attribute :type, ValueOrArraySchema[ValueTypeSchema], require_group: :matcher
      attribute :unless, ValueOrArraySchema[HasValueSchema], require_group: :matcher

      self.or_value_schema = ScalarValueSchema
    end
  end
end

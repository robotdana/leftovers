# frozen_string_literal: true

module Leftovers
  class ConfigLoader
    class HasReceiverSchema < ValueOrObjectSchema
      inherit_attributes_from HasValueSchema, except: :unless

      attribute :literal, ValueOrArraySchema[ScalarValueSchema],
                require_group: :matcher
      attribute :unless, ValueOrArraySchema[HasReceiverSchema], require_group: :matcher

      self.or_value_schema = ScalarValueSchema
    end
  end
end

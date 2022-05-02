# frozen_string_literal: true

module Leftovers
  class ConfigLoader
    class ValueMatcherConditionSchema < ObjectSchema
      attribute :has_arguments, ValueOrArraySchema[HasArgumentSchema], aliases: :has_argument
      attribute :has_receiver, ValueOrArraySchema[HasReceiverSchema]
      attribute :unless, ValueOrArraySchema[ValueMatcherConditionSchema]
      attribute :all, ArraySchema[ValueMatcherConditionSchema]
      attribute :any, ArraySchema[ValueMatcherConditionSchema]
    end
  end
end

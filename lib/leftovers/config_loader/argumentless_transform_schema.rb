# frozen_string_literal: true

module Leftovers
  class ConfigLoader
    class ArgumentlessTransformSchema < StringEnumSchema
      value :original
      value :pluralize
      value :singularize
      value :camelize, aliases: :camelcase
      value :underscore
      value :titleize, aliases: :titlecase
      value :demodulize
      value :deconstantize
      value :parameterize
      value :downcase
      value :upcase
      value :capitalize
      value :swapcase
    end
  end
end

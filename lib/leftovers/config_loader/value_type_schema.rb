# frozen_string_literal: true

module Leftovers
  class ConfigLoader
    class ValueTypeSchema < StringEnumSchema
      value :String
      value :Symbol
      value :Integer
      value :Float
      value :Array
      value :Hash
      value :Proc
      value :Method
      value :Constant
    end
  end
end

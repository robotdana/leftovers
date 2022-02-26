# frozen_string_literal: true

module Leftovers
  class ConfigLoader
    class BuiltInPrecompilerSchema < StringEnumSchema
      value :erb
      value :yaml
      value :json
      value :slim
      value :haml
    end
  end
end

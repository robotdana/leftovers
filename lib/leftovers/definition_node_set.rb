# frozen-string-literal: true

module Leftovers
  class DefinitionNodeSet
    attr_reader :definitions

    def initialize(definitions)
      @definitions = definitions
    end
  end
end

# frozen-string-literal: true

# To give to matchers before creating a Definition

module Leftovers
  class DefinitionNode
    attr_reader :path, :name

    def initialize(name, path)
      @name = name
      @path = path

      freeze
    end

    # these are the methods checked by things in lib/leftovers/matchers
    def kwargs
      nil
    end

    def positional_arguments
      nil
    end

    # these two i'm not sure are possible with the current config flags
    # :nocov:
    def scalar?
      false
    end

    def type
      :leftovers_definition
    end
    # :nocov:
  end
end

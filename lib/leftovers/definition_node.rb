# frozen-string-literal: true

module Leftovers
  class DefinitionNode
    attr_reader :name, :loc, :path

    def initialize(node, name:, location: node.loc.expression)
      @path = node.path
      @name = name
      @loc = location
    end

    def kwargs
      nil
    end

    def positional_arguments
      nil
    end

    def type
      :leftovers_definition
    end

    def first
      nil
    end

    def second
      nil
    end

    def privacy=(_value)
      nil
    end

    def privacy
      :public
    end

    def to_scalar_value
      nil
    end

    def scalar?
      false
    end

    def to_s
      ''
    end

    def to_sym
      :''
    end

    def to_literal_s
      nil
    end

    def hash?
      false
    end

    def proc?
      false
    end

    def as_arguments_list
      [self]
    end

    def arguments
      nil
    end

    def receiver
      nil
    end
  end
end

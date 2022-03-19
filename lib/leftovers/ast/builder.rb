# frozen_string_literal: true

require 'parser'

module Leftovers
  module AST
    class Builder < ::Parser::Builders::Default
      def n(type, children, source_map) # leftovers:keep
        self.class.node_class(type).new(type, children, location: source_map)
      end

      def self.node_class(type) # rubocop:disable Metrics
        case type
        when :array then ArrayNode
        when :block then BlockNode
        when :casgn then CasgnNode
        when :const then ConstNode
        when :def then DefNode
        when :defs then DefsNode
        when :false then FalseNode
        when :hash then HashNode
        when :int, :float then NumericNode
        when :lvar, :ivar, :gvar, :cvar then VarNode
        when :ivasgn, :cvasgn, :gvasgn then VasgnNode
        when :module, :class then ModuleNode
        when :nil then NilNode
        when :send, :csend then SendNode
        when :str then StrNode
        when :sym then SymNode
        when :true then TrueNode
        else Node
        end
      end

      # Don't complain about invalid strings
      # This is called by ::Parser::AST internals
      def string_value(token) # leftovers:keep
        value(token)
      end
    end
  end
end

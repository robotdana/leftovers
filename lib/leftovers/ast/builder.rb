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
        when :array then ::Leftovers::AST::ArrayNode
        when :block then ::Leftovers::AST::BlockNode
        when :casgn then ::Leftovers::AST::CasgnNode
        when :const then ::Leftovers::AST::ConstNode
        when :def then ::Leftovers::AST::DefNode
        when :defs then ::Leftovers::AST::DefsNode
        when :false then ::Leftovers::AST::FalseNode
        when :hash then ::Leftovers::AST::HashNode
        when :int, :float then ::Leftovers::AST::NumericNode
        when :lvar, :ivar, :gvar, :cvar then ::Leftovers::AST::VarNode
        when :ivasgn, :cvasgn, :gvasgn then ::Leftovers::AST::VasgnNode
        when :module, :class then ::Leftovers::AST::ModuleNode
        when :nil then ::Leftovers::AST::NilNode
        when :send, :csend then ::Leftovers::AST::SendNode
        when :str then ::Leftovers::AST::StrNode
        when :sym then ::Leftovers::AST::SymNode
        when :true then ::Leftovers::AST::TrueNode
        else ::Leftovers::AST::Node
        end
      end

      # Don't complain about invalid strings
      def string_value(token) # leftovers:keep
        value(token)
      end
    end
  end
end

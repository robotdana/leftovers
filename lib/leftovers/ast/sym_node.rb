# frozen_string_literal: true

module Leftovers
  module AST
    class SymNode < ::Leftovers::AST::Node
      alias_method :name, :first
      alias_method :to_scalar_value, :first
      alias_method :to_sym, :first

      def scalar?
        true
      end

      def to_s
        name.to_s
      end

      def string_or_symbol?
        true
      end

      def string_or_symbol_or_def?
        true
      end
    end
  end
end

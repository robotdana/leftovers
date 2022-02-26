# frozen_string_literal: true

module Leftovers
  module AST
    class DefNode < ::Leftovers::AST::Node
      def string_or_symbol_or_def?
        true
      end

      alias_method :name, :first
      alias_method :to_sym, :first

      def to_s
        name.to_s
      end
    end
  end
end

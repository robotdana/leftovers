# frozen_string_literal: true

module Leftovers
  module AST
    class DefsNode < ::Leftovers::AST::Node
      def string_or_symbol_or_def?
        true
      end

      alias_method :name, :second
      alias_method :to_sym, :second

      def to_s
        name.to_s
      end
    end
  end
end

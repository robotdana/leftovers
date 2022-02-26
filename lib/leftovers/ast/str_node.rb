# frozen_string_literal: true

module Leftovers
  module AST
    class StrNode < ::Leftovers::AST::Node
      alias_method :to_scalar_value, :first

      def name
        first.to_sym
      end

      alias_method :to_s, :first

      def to_sym
        to_s.to_sym
      end

      def scalar?
        true
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

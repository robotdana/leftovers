# frozen_string_literal: true

module Leftovers
  module AST
    class NumericNode < ::Leftovers::AST::Node
      alias_method :to_scalar_value, :first

      def scalar?
        true
      end

      def to_s
        to_scalar_value.to_s
      end
      alias_method :to_literal_s, :to_s

      def to_sym
        to_s.to_sym
      end
    end
  end
end

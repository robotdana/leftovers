# frozen_string_literal: true

module Leftovers
  module AST
    class StrNode < ::Leftovers::AST::Node
      alias_method :to_scalar_value, :first

      def name
        first.to_sym
      end

      alias_method :to_s, :first
      alias_method :to_literal_s, :to_s

      def to_sym
        to_s.to_sym
      end

      def scalar?
        true
      end
    end
  end
end

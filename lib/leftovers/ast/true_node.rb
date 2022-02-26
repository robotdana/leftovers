# frozen_string_literal: true

module Leftovers
  module AST
    class TrueNode < ::Leftovers::AST::Node
      def to_scalar_value
        true
      end

      def scalar?
        true
      end

      def to_s
        'true'
      end

      def to_sym
        :true
      end
    end
  end
end

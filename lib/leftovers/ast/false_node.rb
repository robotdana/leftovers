# frozen_string_literal: true

module Leftovers
  module AST
    class FalseNode < ::Leftovers::AST::Node
      def to_scalar_value
        false
      end

      def scalar?
        true
      end

      def to_s
        'false'
      end

      def to_sym
        :false
      end
    end
  end
end

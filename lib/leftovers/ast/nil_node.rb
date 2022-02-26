# frozen_string_literal: true

module Leftovers
  module AST
    class NilNode < ::Leftovers::AST::Node
      def to_scalar_value
        nil
      end

      def scalar?
        true
      end

      def to_s
        ''
      end

      def to_sym
        :nil
      end
    end
  end
end

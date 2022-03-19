# frozen_string_literal: true

module Leftovers
  module AST
    class TrueNode < Node
      def to_scalar_value
        true
      end

      def scalar?
        true
      end

      def to_s
        'true'
      end
      alias_method :to_literal_s, :to_s

      def to_sym
        :true
      end
    end
  end
end

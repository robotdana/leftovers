# frozen_string_literal: true

module Leftovers
  module AST
    class FalseNode < Node
      def to_scalar_value
        false
      end

      def scalar?
        true
      end

      def to_s
        'false'
      end
      alias_method :to_literal_s, :to_s

      def to_sym
        :false
      end
    end
  end
end

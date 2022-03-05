# frozen_string_literal: true

module Leftovers
  module AST
    class DefNode < ::Leftovers::AST::Node
      alias_method :name, :first
      alias_method :to_sym, :first

      def to_s
        name.to_s
      end
      alias_method :to_literal_s, :to_s
    end
  end
end

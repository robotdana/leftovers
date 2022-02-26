# frozen_string_literal: true

module Leftovers
  module AST
    class ConstNode < ::Leftovers::AST::Node
      alias_method :receiver, :first
      alias_method :name, :second
      alias_method :to_sym, :second

      def to_s
        name.to_s
      end
    end
  end
end

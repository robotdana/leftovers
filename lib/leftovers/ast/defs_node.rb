# frozen_string_literal: true

module Leftovers
  module AST
    class DefsNode < ::Leftovers::AST::Node
      alias_method :name, :second
      alias_method :to_sym, :second

      def to_s
        name.to_s
      end
      alias_method :to_literal_s, :to_s
    end
  end
end

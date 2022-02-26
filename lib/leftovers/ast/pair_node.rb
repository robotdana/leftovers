# frozen_string_literal: true

module Leftovers
  module AST
    class PairNode < ::Leftovers::AST::Node
      def name
        first.name
      end

      alias_method :to_sym, :name
    end
  end
end

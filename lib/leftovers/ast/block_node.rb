# frozen_string_literal: true

module Leftovers
  module AST
    class BlockNode < ::Leftovers::AST::Node
      def proc?
        name = first.name
        name == :lambda || name == :proc
      end
    end
  end
end

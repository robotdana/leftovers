# frozen_string_literal: true

module Leftovers
  module AST
    class BlockNode < Node
      def proc?
        name = first.name
        name == :lambda || name == :proc
      end
    end
  end
end

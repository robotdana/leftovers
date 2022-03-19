# frozen_string_literal: true

module Leftovers
  module AST
    class ModuleNode < Node
      def name
        first.name
      end
      alias_method :to_sym, :name

      def to_s
        name.to_s
      end
    end
  end
end

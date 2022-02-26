# frozen_string_literal: true

module Leftovers
  module AST
    class CasgnNode < ::Leftovers::AST::Node
      include Leftovers::AST::HasArguments

      alias_method :name, :second
      alias_method :to_sym, :second

      def to_s
        name.to_s
      end

      def arguments
        children[2].as_arguments_list
      end
    end
  end
end

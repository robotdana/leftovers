# frozen_string_literal: true

module Leftovers
  module AST
    class VasgnNode < Node
      include HasArguments

      alias_method :name, :first
      alias_method :to_sym, :first

      def to_s
        name.to_s
      end

      def arguments
        second.as_arguments_list
      end
    end
  end
end

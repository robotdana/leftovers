# frozen_string_literal: true

module Leftovers
  module AST
    class ArrayNode < ::Leftovers::AST::Node
      include Leftovers::AST::HasArguments

      alias_method :arguments, :children
      alias_method :as_arguments_list, :arguments
    end
  end
end

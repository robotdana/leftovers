# frozen_string_literal: true

module Leftovers
  module AST
    class ArrayNode < Node
      include HasArguments

      alias_method :arguments, :children
      alias_method :as_arguments_list, :arguments
    end
  end
end

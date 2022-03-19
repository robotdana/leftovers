# frozen_string_literal: true

module Leftovers
  module AST
    class HashNode < Node
      include HasArguments

      def arguments
        @memo[:arguments] ||= [self]
      end

      def hash?
        true
      end
    end
  end
end

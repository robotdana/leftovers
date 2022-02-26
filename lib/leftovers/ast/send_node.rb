# frozen_string_literal: true

module Leftovers
  module AST
    class SendNode < ::Leftovers::AST::Node
      include Leftovers::AST::HasArguments

      alias_method :receiver, :first
      alias_method :name, :second
      alias_method :to_sym, :second

      def to_s
        name.to_s
      end

      def arguments
        @memo.fetch(:arguments) do
          @memo[:arguments] = children.drop(2)
        end
      end

      def as_arguments_list
        first.as_arguments_list if name == :freeze
      end
    end
  end
end

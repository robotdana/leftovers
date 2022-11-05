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
        @memo[:arguments] ||= if block_pass_argument?
          children[2...-1]
        else
          children.drop(2)
        end
      end

      def as_arguments_list
        first.as_arguments_list if name == :freeze
      end

      def block_pass_argument?
        last_child = children.last
        last_child.respond_to?(:type) && last_child.type == :block_pass
      end

      def block_given?
        block_pass_argument? || parent&.type == :block
      end
    end
  end
end

# frozen_string_literal: true

require 'parser'

module Leftovers
  module AST
    class Node < ::Parser::AST::Node
      def initialize(type, children = [], properties = {})
        # ::AST::Node#initialize freezes itself.
        # so can't use normal memoizations
        @memo = {}

        super
      end

      # This is called by ::Parser::AST internals
      def updated(type = nil, children = nil, properties = nil) # leftovers:keep
        maybe_copy = super

        class_for_type = Builder.node_class(maybe_copy.type)
        return maybe_copy if maybe_copy.instance_of?(class_for_type)

        class_for_type.new(maybe_copy.type, maybe_copy.children, location: maybe_copy.loc)
      end

      def first
        children.first
      end

      def second
        children[1]
      end

      def path
        loc.expression.source_buffer.name
      end

      def privacy=(value)
        @memo[:privacy] = value
      end

      def privacy
        @memo[:privacy] || :public
      end

      def parent
        @memo[:parent]
      end

      def parent=(value)
        @memo[:parent] = value
      end

      def to_scalar_value
        nil
      end

      def scalar?
        false
      end

      def to_s
        ''
      end

      def to_sym
        :''
      end

      def to_literal_s
        nil
      end

      def hash?
        false
      end

      def proc?
        false
      end

      def sym?
        false
      end

      def as_arguments_list
        @memo[:as_arguments_list] ||= [self]
      end

      def arguments
        nil
      end

      def positional_arguments
        nil
      end

      def receiver
        nil
      end

      def kwargs
        nil
      end

      def name
        nil
      end

      def block_given?
        false
      end
    end
  end
end

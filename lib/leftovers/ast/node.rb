# frozen_string_literal: true

require 'parser'

module Leftovers
  module AST
    class Node < ::Parser::AST::Node # rubocop:disable Metrics/ClassLength
      def initialize(type, children = [], properties = {})
        # ::AST::Node#initialize freezes itself.
        # so can't use normal memoizations
        @memo = {}

        super
      end

      def first
        children.first
      end

      def second
        children[1]
      end

      def path
        @memo[:path] ||= loc.expression.source_buffer.name.to_s
      end

      def test?
        @memo[:test]
      end

      def test=(value)
        @memo[:test] = value
      end

      def keep_line=(value)
        @memo[:keep_line] = value
      end

      def keep_line?
        @memo[:keep_line]
      end

      def to_scalar_value
        case type
        when :sym, :int, :float, :str
          first
        when :true
          true
        when :false
          false
        when :nil
          nil
        end
      end

      def scalar?
        case type
        when :sym, :int, :float, :str, :true, :false, :nil
          true
        else false
        end
      end

      def to_s
        @memo[:to_s] ||= name ? name.to_s : to_scalar_value.to_s
      end

      def to_sym
        case type
        when :sym then first
        when :nil, :true, :false then type
        else to_s.to_sym
        end
      end

      def string_or_symbol?
        type == :str || type == :sym
      end

      def arguments
        @memo.fetch(:arguments) do
          @memo[:arguments] = case type
          when :send, :csend then children.drop(2)
          when :casgn then assign_arguments(children[2])
          when :ivasgn, :cvasgn, :gvasgn then assign_arguments(second)
          when :array then children
          when :hash then [self]
          end
        end
      end

      def assign_arguments(arguments_list)
        arguments_list = arguments_list.unwrap_freeze
        case arguments_list.type
        when :array
          arguments_list.children
        when :hash, :str, :sym
          [arguments_list]
        end
      end

      def positional_arguments
        @memo.fetch(:positional_arguments) do
          @memo[:positional_arguments] = kwargs ? arguments[0...-1] : arguments
        end
      end

      def unwrap_freeze
        return self unless type == :send && name == :freeze

        first
      end

      def kwargs
        @memo.fetch(:kwargs) do
          @memo[:kwargs] = begin
            args = arguments
            next unless args

            last_arg = args[-1]
            last_arg if last_arg && last_arg.type == :hash
          end
        end
      end

      def name
        @memo[:name] ||= case type
        when :send, :csend, :casgn, :const
          second
        when :def, :ivasgn, :ivar, :gvar, :cvar, :gvasgn, :cvasgn, :sym
          first
        when :str
          first.to_sym
        when :module, :class, :pair
          first.name
        end
      end
    end
  end
end

# frozen_string_literal: true

require 'parser'

module Leftovers
  module AST
    class Node < Parser::AST::Node # rubocop:disable Metrics/ClassLength
      # :nocov:
      using ::Leftovers::SetCaseEq if defined?(::Leftovers::SetCaseEq)
      # :nocov:

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
        @memo[:path] ||= loc.expression.source_buffer.name
      end

      def test?
        @memo[:test]
      end

      def test=(value)
        @memo[:test] = value
      end

      def to_scalar_value # rubocop:disable Metrics/MethodLength
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

      def arguments # rubocop:disable Metrics/MethodLength
        @memo[:arguments] ||= case type
        when :send, :csend then children.drop(2)
        when :casgn then [children[2]]
        when :ivasgn, :cvasgn, :gvasgn then [second]
        else
          # :nocov: # these are all the nodes with collect_rules
          raise "Not argument node (#{type})"
          # :nocov:
        end
      end

      def positional_arguments
        @memo[:positional_arguments] ||= kwargs ? arguments[0...-1] : arguments
      end

      def unwrap_freeze
        return self unless type == :send && name == :freeze

        first
      end

      def kwargs
        @memo.fetch(:kwargs) do
          last_arg = arguments[-1]&.unwrap_freeze
          @memo[:kwargs] = (last_arg if last_arg&.type == :hash)
        end
      end

      def keys
        each_pair.map { |k, _| k }
      end

      def values
        # :nocov:
        @memo[:kwargs] ||= case type
        # :nocov:
        when :hash then each_pair.map { |_, v| v }
        when :array then children
        end
      end

      def pair_value
        second if type == :pair
      end

      def values_at_match(matcher)
        each_pair.with_object([]) do |(key, value), values|
          values << value if matcher === key.to_sym
        end
      end

      def positional_arguments_at(positions)
        positional_arguments.values_at(*positions).compact
      end

      def each_pair
        return enum_for(:each_pair) unless block_given?

        children.each do |pair|
          yield(*pair.children) if pair.type == :pair
        end
      end

      def name # rubocop:disable Metrics/MethodLength
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

      def [](index) # rubocop:disable Metrics/MethodLength, Metrics/CyclomaticComplexity
        # :nocov:
        case type
        # :nocov:
        when :send, :csend, :casgn, :cvasgn, :ivasgn, :gvasgn
          index.is_a?(Integer) ? arguments[index - 1] : kwargs && kwargs[index]
        when :hash
          each_pair do |key, value|
            next unless key.string_or_symbol?

            return value if key.to_sym == index
          end

          nil
        end
      end
    end
  end
end

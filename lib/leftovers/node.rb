# frozen_string_literal: true

require 'parser'

module Parser
  module AST
    class Node # rubocop:disable Metrics/ClassLength
      def initialize(type, children = [], properties = {})
        # ::AST::Node#initialize freezes itself.
        # so can't use normal memoizations
        @memo = {}

        super
      end

      def first
        children.first
      end

      def file
        @memo[:file]
      end

      def file=(value)
        @memo[:file] = value
      end

      def test
        @memo[:test]
      end
      alias_method :test?, :test

      def test=(value)
        @memo[:test] = value
      end

      def to_scalar_value # rubocop:disable Metrics/MethodLength
        @memo[:scalar_value] ||= case type
        when :sym
          first
        when :str
          first.to_s.freeze
        when :true
          true
        when :false
          false
        when :nil
          nil
        else
          raise "Not scalar node, (#{type})"
        end
      end

      def to_s # rubocop:disable Metrics/MethodLength
        @memo[:to_s] ||= if scalar?
          to_scalar_value
        elsif named?
          name
        else
          raise "No to_s, (#{type})"
        end.to_s.freeze
      end

      def to_sym
        case type
        when :str, :sym then first
        when :nil, :true, :false then type
        else to_s.to_sym
        end
      end

      SCALAR_TYPES = %i{sym str true false nil}.freeze
      def scalar?
        SCALAR_TYPES.include?(type)
      end

      def string_or_symbol?
        type == :str || type == :sym
      end

      def send?
        type == :send || type == :csend
      end

      def named?
        send? || type == :casgn
      end

      def arguments
        @memo[:arguments] ||= case type
        when :send, :csend then children.drop(2)
        when :casgn then [children[2]]
        else raise "Not argument node (#{type})"
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

      def key?(key)
        each_pair.find do |k, _v|
          next unless k.string_or_symbol?

          k.to_sym == key
        end
      end

      def values
        @memo[:kwargs] ||= case type
        when :hash then each_pair.map { |_, v| v }
        when :array then children
        else []
        end
      end

      def values_at_match(matcher)
        each_pair.with_object([]) do |(key, value), values|
          values << value if matcher.match?(key.to_sym, key.to_s)
        end
      end

      def positional_arguments_at(positions)
        positional_arguments.values_at(*positions).compact
      end

      def each_pair
        raise "not hash node (#{type})" unless type == :hash

        return enum_for(:each_pair) unless block_given?

        children.each do |pair|
          yield(*pair.children) if pair.type == :pair
        end
      end

      def name
        return "Not named node (#{type})" unless named?

        @memo[:name] ||= children[1]
      end

      def name_s
        @memo[:name_s] ||= name.to_s.freeze
      end

      def [](index) # rubocop:disable Metrics/MethodLength, Metrics/CyclomaticComplexity
        case type
        when :send, :csend
          index.is_a?(Integer) ? arguments[index] : kwargs && kwargs[index]
        when :array
          children[index]
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

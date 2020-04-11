require 'parser'

module Parser
  module AST
    class Node
      def initialize(type, children = [], properties = {})
        # ::AST::Node#initialize freezes itself.
        # so can't use normal memoizations
        @memo = {}

        super
      end

      def first
        children.first
      end

      def to_scalar_value
        case type
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

      def to_s
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

      SCALAR_TYPES=%i{sym str true false nil}
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
        send?
      end

      def arguments
        raise "Not send node (#{type})" unless send?

        @memo[:arguments] ||= children.drop(2)
      end

      def positional_arguments
        @memo[:positional_arguments] ||= kwargs ? arguments[0...-1] : arguments
      end

      def kwargs
        @memo.fetch(:kwargs) do
          last_arg = arguments[-1]
          @memo[:kwargs] = (last_arg if last_arg&.type == :hash)
        end
      end

      def keys
        each_pair.map { |k,_| k }
      end

      def key?(key)
        each_pair.find do |k, v|
          next unless k.string_or_symbol?

          k.to_sym == key
        end
      end

      def values
        @memo[:kwargs] ||= case type
        when :hash then each_pair.map { |_,v| v }
        when :array then children
        else []
        end
      end

      def values_at_match(matcher)
        each_pair.with_object([]) do |(key, value), values|
          values << value if matcher.match?(key.to_s)
        end
      end

      def each_pair
        raise "not hash node (#{type})" unless type == :hash

        return enum_for(:each_pair) unless block_given?

        children.each do |pair|
          next unless pair.type == :pair

          yield(*pair.children)
        end
      end

      def name
        return "Not named node (#{type})" unless named?

        @memo[:name] ||= children[1]
      end

      def name_s
        @memo[:name_s] ||= name.to_s.freeze
      end

      def [](index)
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

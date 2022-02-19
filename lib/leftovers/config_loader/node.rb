# frozen_string_literal: true

module Leftovers
  class ConfigLoader
    class Node
      class_loader = Psych::ClassLoader::Restricted.new([], [])
      ToRuby = Psych::Visitors::ToRuby.new(
        Psych::ScalarScanner.new(class_loader),
        class_loader
      )

      attr_reader :node, :file, :name
      attr_accessor :error

      def initialize(node, file, name = nil)
        @node = node
        @file = file
        @name = name
      end

      def name_
        "#{name} " if name
      end

      def valid?
        !error
      end

      def error_message
        "Config SchemaError: #{location} #{@error}" if @error
      end

      def all_errors
        Array(error_message) + children.flat_map(&:all_errors)
      end

      def to_s
        to_ruby.to_s
      end

      def hash?
        node.is_a?(Psych::Nodes::Mapping)
      end

      def location
        "#{file.relative_path}:#{node.start_line + 1}:#{node.start_column}"
      end

      def children
        @children ||= if hash?
          prepare_hash_children
        elsif array?
          node.children.map { |value| self.class.new(value, file, "#{name} value") }
        else
          []
        end
      end

      def keys
        @keys ||= pairs.map(&:first)
      end

      def pairs
        @pairs ||= children.each_slice(2).to_a
      end

      def each_key(&block)
        keys.each(&block)
      end

      def to_ruby
        @to_ruby ||= ToRuby.accept(node)
      end

      def to_sym
        to_ruby.to_sym if string?
      end

      def string?
        to_ruby.is_a?(String)
      end

      def scalar?
        !array? and !hash?
      end

      def array?
        node.is_a?(Psych::Nodes::Sequence)
      end

      def integer?
        to_ruby.is_a?(Integer)
      end

      private

      def prepare_hash_children
        node.children.each_slice(2).flat_map do |key, value|
          key = self.class.new(key, file, name)
          value = self.class.new(value, file, key.to_ruby)
          [key, value]
        end
      end
    end
  end
end

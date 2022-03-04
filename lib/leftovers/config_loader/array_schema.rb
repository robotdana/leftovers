# frozen_string_literal: true

module Leftovers
  class ConfigLoader
    class ArraySchema < Schema
      class << self
        def [](value_schema)
          new(value_schema)
        end
      end

      attr_reader :value_schema

      def initialize(value_schema)
        @value_schema = value_schema

        super()
      end

      def validate(node)
        validate_array(node) && validate_length(node) && validate_values(node)
      end

      def to_ruby(node)
        node.children.map do |value|
          value_schema.to_ruby(value)
        end
      end

      private

      def validate_array(node)
        self.class.error(node, 'be an array') unless node.array?

        node.valid?
      end

      def validate_length(node)
        self.class.error(node, 'not be empty') if node.children.empty?

        node.valid?
      end

      def validate_values(node)
        node.children.each do |value|
          value_schema.validate(value)
        end

        node.children.all?(&:valid?)
      end
    end
  end
end

# frozen_string_literal: true

module Leftovers
  class ConfigLoader
    class ValueOrArraySchema < Schema
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
        if node.array?
          validate_length(node) && validate_values(node)
        else
          validate_or_schema(node)
        end
      end

      def to_ruby(node)
        if node.array?
          Leftovers.unwrap_array(
            node.children.map do |value|
              value_schema.to_ruby(value)
            end
          )
        else
          value_schema.to_ruby(node)
        end
      end

      private

      def validate_or_schema(node)
        value_schema.validate(node)
        return true if node.valid?

        node.error += ' or an array'

        false
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

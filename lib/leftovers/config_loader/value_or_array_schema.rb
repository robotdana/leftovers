# frozen_string_literal: true

module Leftovers
  class ConfigLoader
    class ValueOrArraySchema < ArraySchema
      def validate(node)
        if node.array?
          validate_length(node) && validate_values(node)
        else
          validate_or_schema(node)
        end
      end

      def to_ruby(node)
        if node.array?
          ::Leftovers.unwrap_array(super)
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
    end
  end
end

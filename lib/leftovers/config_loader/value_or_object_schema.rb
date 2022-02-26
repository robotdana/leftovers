# frozen_string_literal: true

module Leftovers
  class ConfigLoader
    class ValueOrObjectSchema < ObjectSchema
      class << self
        attr_accessor :or_value_schema

        def validate(node)
          if node.hash?
            super(node)
          else
            validate_or_value_schema(node)
          end
        end

        def to_ruby(node)
          if node.hash?
            super
          else
            or_value_schema.to_ruby(node)
          end
        end

        private

        def validate_or_value_schema(node)
          or_value_schema.validate(node)
          return true if node.valid?

          if node.string? && attribute_for_key(node)
            node.error = "#{node.name_}#{node.to_sym} must be a hash key"
          else
            node.error += " or a hash with any of #{suggestions.join(', ')}"
          end
        end
      end
    end
  end
end

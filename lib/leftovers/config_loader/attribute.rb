# frozen_string_literal: true

module Leftovers
  class ConfigLoader
    class Attribute
      attr_reader(
        :name,
        :aliases, :schema # leftovers:test_only
      )

      attr_accessor :require_group

      def initialize(name, schema, aliases: nil, require_group: nil, suggest: true)
        @name = name
        @schema = schema
        @aliases = aliases
        @require_group = require_group
        @suggest = suggest
      end

      def without_require_group
        new = dup
        new.require_group = nil
        new
      end

      def suggest?
        @suggest
      end

      def attributes
        [self]
      end

      def name?(name)
        name = name.to_sym

        @name == name || ::Leftovers.each_or_self(@aliases).include?(name)
      end

      def to_ruby(value)
        [key_to_ruby, @schema.to_ruby(value)]
      end

      def validate_value(value)
        @schema.validate(value)
      end

      private

      def key_to_ruby
        name == :unless ? :unless_arg : name
      end
    end
  end
end

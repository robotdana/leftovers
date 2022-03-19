# frozen_string_literal: true

module Leftovers
  class ConfigLoader
    class InheritSchemaAttributes
      def initialize(schema, require_group: true, except: nil)
        @schema = schema
        @use_require_groups = require_group
        @except = ::Leftovers.each_or_self(except)
      end

      def attributes
        @schema.attributes.map do |attr|
          next if @except.include?(attr.name)
          next attr.without_require_group unless @use_require_groups

          attr
        end.compact
      end
    end
  end
end

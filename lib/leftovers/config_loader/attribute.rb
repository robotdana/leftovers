# frozen_string_literal: true

module Leftovers
  class ConfigLoader
    class Attribute
      def initialize(name, value_schema, aliases: nil, require_group: nil)
        @name = name
        @value_schema = value_schema
        @aliases = aliases
        @require_group = require_group
      end

      def attributes
        { @name => @value_schema }
      end

      def aliases
        ::Leftovers.each_or_self(@aliases).map do |aka|
          [aka, @name]
        end.to_h
      end

      def require_groups
        return {} unless @require_group

        { @require_group => [@name, *::Leftovers.each_or_self(@aliases)] }
      end
    end
  end
end

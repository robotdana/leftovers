# frozen_string_literal: true

module Leftovers
  class ValueRule
    def initialize(values) # rubocop:disable Metrics/MethodLength, Metrics/CyclomaticComplexity, Metrics/AbcSize, Metrics/PerceivedComplexity
      literal_values = Set.new
      value_types = Set.new

      Leftovers.each_or_self(values) do |value|
        case value
        when Hash
          raise Leftovers::ConfigError, "invalid value #{value.inspect}" unless value[:type]

          value_types.merge(
            Array(value[:type]).map do |v|
              case v
              when 'String' then :str
              when 'Symbol' then :sym
              when 'Integer' then :int
              else v.to_s.downcase.to_sym
              end
            end
          )
        else
          literal_values << value
        end
      end

      if literal_values.length <= 1
        @literal_value = literal_values.first
        @literal_values = nil
      else
        @literal_value = nil
        @literal_values = literal_values
      end

      if value_types.length <= 1
        @value_type = value_types.first
        @value_types = nil
      else
        @value_type = nil
        @value_types = value_types
      end

      freeze
    end

    def match?(value_node) # rubocop:disable Metrics/CyclomaticComplexity, Metrics/PerceivedComplexity
      return true if @value_type&.== value_node.type
      return true if @value_types&.include?(value_node.type)
      return false unless (@literal_value || @literal_values) && value_node.scalar?
      return true if @literal_value&.== value_node.to_scalar_value

      @literal_values&.include?(value_node.to_scalar_value)
    end
  end
end

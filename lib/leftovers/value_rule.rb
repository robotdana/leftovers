# frozen_string_literal: true

module Leftovers
  class ValueRule
    def initialize(values) # rubocop:disable Metrics/MethodLength, Metrics/CyclomaticComplexity, Metrics/AbcSize,
      literal_values = Set.new
      value_types = Set.new

      Array.each_or_self(values) do |value|
        case value
        when Hash
          raise ArgumentError, "invalid value #{value.inspect}" unless value[:type]

          value_types.merge(
            Array(value[:type]).map do |v|
              case v
              when 'String', :String then :str
              when 'Symbol', :Symbol then :sym
              else v.to_s.downcase.to_sym
              end
            end
          )
        else
          (literal_values << value) if value
        end
      end

      case literal_values.length
      when 0 then nil
      when 1
        @literal_value = literal_values.first
      else
        @literal_values = literal_values
      end

      case value_types.length
      when 0 then nil
      when 1
        @value_type = value_types.first
      else
        @value_types = value_types
      end

      freeze
    end

    def match?(value_node) # rubocop:disable Metrics/CyclomaticComplexity
      return true if @value_type&.== value_node.type
      return true if @value_types&.include?(value_node.type)
      return false unless (@literal_value || @literal_values) && value_node.scalar?
      return true if @literal_value&.== value_node.to_scalar_value

      @literal_values&.include?(value_node.to_scalar_value)
    end
  end
end

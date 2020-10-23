# frozen_string_literal: true

module Leftovers
  module ProcessorBuilders
    module EachForDefinitionSet
      def self.each_or_self(value, &block)
        case value
        when nil then nil
        when Array then build(value.map(&block))
        else build([yield(value)])
        end
      end

      def self.build(processors)
        processors = compact(processors)

        case processors.length
        when 0 then nil
        when 1 then processors.first
        else ::Leftovers::ValueProcessors::EachForDefinitionSet.new(processors)
        end
      end

      def self.flatten(value) # rubocop:disable Metrics/MethodLength
        case value
        when ::Leftovers::ValueProcessors::EachForDefinitionSet
          ret = value.processors.map { |v| flatten(v) }
          ret.flatten!(1)
          ret
        when Array
          ret = value.map { |v| flatten(v) }
          ret.flatten!(1)
          ret
        else
          value
        end
      end

      def self.compact(processors)
        return processors if processors.length <= 1

        processors = flatten(processors)
        processors.compact!

        processors
      end
    end
  end
end

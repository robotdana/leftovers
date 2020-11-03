# frozen_string_literal: true

module Leftovers
  module ProcessorBuilders
    module EachForDefinitionSet
      def self.each_or_self(value, &block)
        case value
        # :nocov:
        when nil then raise
        # :nocov:
        when Array then build(value.map(&block))
        else build([yield(value)])
        end
      end

      def self.build(processors)
        processors = compact(processors)

        case processors.length
        # :nocov:
        when 0 then raise
        # :nocov:
        when 1 then processors.first
        else ::Leftovers::ValueProcessors::EachForDefinitionSet.new(processors)
        end
      end

      def self.compact(processors)
        processors.flatten!
        processors.compact!

        processors
      end
    end
  end
end

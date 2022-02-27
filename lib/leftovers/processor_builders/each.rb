# frozen_string_literal: true

module Leftovers
  module ProcessorBuilders
    module Each
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
        # :nocov:
        when 0 then raise Leftovers::UnexpectedCase, "Unhandled value #{processors.inspect}"
        # :nocov:
        when 1 then processors.first
        else ::Leftovers::ValueProcessors::Each.new(processors)
        end
      end

      def self.flatten(processors)
        case processors
        when ::Leftovers::ValueProcessors::Each
          flatten(processors.processors)
        when Array
          processors.flat_map { |v| flatten(v) }
        else
          [processors]
        end
      end

      def self.compact(processors)
        flatten(processors).compact
      end
    end
  end
end

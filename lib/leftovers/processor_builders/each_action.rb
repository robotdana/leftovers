# frozen_string_literal: true

module Leftovers
  module ProcessorBuilders
    module EachAction
      class << self
        def each_or_self(value, &block)
          case value
          when nil then nil
          when Array then build(value.map(&block))
          else build([yield(value)])
          end
        end

        def build(processors)
          processors = compact(processors)

          case processors.length
          # :nocov:
          when 0 then raise Leftovers::UnexpectedCase, "Unhandled value #{processors.inspect}"
          # :nocov:
          when 1 then processors.first
          else ::Leftovers::ValueProcessors::Each.new(processors)
          end
        end

        private

        def flatten(value)
          case value
          when ::Leftovers::ValueProcessors::Each
            value.processors.flat_map { |v| flatten(v) }
          when Array
            value.flat_map { |v| flatten(v) }
          else
            value
          end
        end

        def compact(processors)
          return processors if processors.length <= 1

          processors = flatten(processors)
          processors.compact!

          processors
        end
      end
    end
  end
end

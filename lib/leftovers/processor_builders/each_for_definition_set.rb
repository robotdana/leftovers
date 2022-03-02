# frozen_string_literal: true

module Leftovers
  module ProcessorBuilders
    module EachForDefinitionSet
      class << self
        def each_or_self(value, &block)
          case value
          # :nocov:
          when nil then raise Leftovers::UnexpectedCase, "Unhandled value #{value.inspect}"
          # :nocov:
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
          else ::Leftovers::Processors::EachForDefinitionSet.new(processors)
          end
        end

        private

        def compact(processors)
          processors.flatten!
          processors.compact!

          processors
        end
      end
    end
  end
end

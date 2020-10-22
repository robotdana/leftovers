# frozen_string_literal: true

require_relative '../rule_processors/null'
require_relative '../rule_processors/each'

module Leftovers
  module ProcessorBuilders
    module EachRule
      def self.each_or_self(value, &block)
        case value
        when nil then ::Leftovers::RuleProcessors::Null
        when Array then build(value.map(&block))
        else build([yield(value)])
        end
      end

      def self.build(processors)
        processors = compact(processors)

        case processors.length
        when 0 then ::Leftovers::RuleProcessors::Null
        when 1 then processors.first
        else ::Leftovers::RuleProcessors::Each.new(processors)
        end
      end

      def self.flatten(value) # rubocop:disable Metrics/MethodLength
        case value
        when ::Leftovers::RuleProcessors::Each
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

        processors.reject! do |p|
          p == ::Leftovers::RuleProcessors::Null
        end

        processors
      end
    end
  end
end

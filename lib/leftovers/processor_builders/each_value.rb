# frozen_string_literal: true

require_relative 'each_for_call'
require_relative 'each_for_definition'

module Leftovers
  module ProcessorBuilders
    module EachValue
      def self.each_or_self(value, action, &block)
        case action
        when :call
          ::Leftovers::ProcessorBuilders::EachForCall.each_or_self(value, &block)
        when :define
          ::Leftovers::ProcessorBuilders::EachForDefinition.each_or_self(value, &block)
        else raise
        end
      end

      def self.build(processors, action)
        case action
        when :call
          ::Leftovers::ProcessorBuilders::EachForCall.build(processors)
        when :define
          ::Leftovers::ProcessorBuilders::EachForDefinition.build(processors)
        else raise
        end
      end
    end
  end
end

# frozen_string_literal: true

module Leftovers
  module ProcessorBuilders
    module AddSuffix
      def self.build(argument, then_processor)
        case argument
        when ::Hash
          dynamic_suffix = ::Leftovers::ProcessorBuilders::Action.build(argument, :call)
          ::Leftovers::ValueProcessors::AddDynamicSuffix.new(dynamic_suffix, then_processor)
        when ::String
          ::Leftovers::ValueProcessors::AddSuffix.new(argument, then_processor)
        else raise
        end
      end
    end
  end
end

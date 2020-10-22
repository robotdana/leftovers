# frozen_string_literal: true

require_relative 'action'
require_relative '../value_processors/add_dynamic_prefix'
require_relative '../value_processors/add_prefix'

module Leftovers
  module ProcessorBuilders
    module AddPrefix
      def self.build(argument, then_processor)
        case argument
        when ::Hash
          dynamic_prefix = ::Leftovers::ProcessorBuilders::Action.build(argument, :call)
          ::Leftovers::ValueProcessors::AddDynamicPrefix.new(dynamic_prefix, then_processor)
        when ::String
          ::Leftovers::ValueProcessors::AddPrefix.new(argument, then_processor)
        else raise
        end
      end
    end
  end
end

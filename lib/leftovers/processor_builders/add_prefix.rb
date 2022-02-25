# frozen_string_literal: true

module Leftovers
  module ProcessorBuilders
    module AddPrefix
      def self.build(argument, then_processor)
        case argument
        when ::Hash
          dynamic_prefix = ::Leftovers::ProcessorBuilders::Action.build(argument, :sym)
          ::Leftovers::ValueProcessors::AddDynamicPrefix.new(dynamic_prefix, then_processor)
        when ::String
          ::Leftovers::ValueProcessors::AddPrefix.new(argument, then_processor)
          # :nocov:
        else raise Leftovers::UnexpectedCase, "Unhandled value #{argument.inspect}"
          # :nocov:
        end
      end
    end
  end
end

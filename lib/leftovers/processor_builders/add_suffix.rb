# frozen_string_literal: true

module Leftovers
  module ProcessorBuilders
    module AddSuffix
      def self.build(argument, then_processor)
        case argument
        when ::Hash
          dynamic_suffix = ::Leftovers::ProcessorBuilders::Action.build(
            argument, ::Leftovers::Processors::AppendSym
          )
          ::Leftovers::Processors::AddDynamicSuffix.new(dynamic_suffix, then_processor)
        when ::String
          ::Leftovers::Processors::AddSuffix.new(argument, then_processor)
          # :nocov:
        else raise Leftovers::UnexpectedCase, "Unhandled value #{argument.inspect}"
          # :nocov:
        end
      end
    end
  end
end

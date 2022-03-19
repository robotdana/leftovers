# frozen_string_literal: true

module Leftovers
  module ProcessorBuilders
    module AddPrefix
      class << self
        def build(argument, then_processor)
          case argument
          when ::Hash then build_hash(argument, then_processor)
          when ::String then Processors::AddPrefix.new(argument, then_processor)
            # :nocov:
          else raise UnexpectedCase, "Unhandled value #{argument.inspect}"
            # :nocov:
          end
        end

        private

        def build_hash(argument, then_processor)
          dynamic_prefix = Action.build(argument, Processors::AppendSym)
          Processors::AddDynamicPrefix.new(dynamic_prefix, then_processor)
        end
      end
    end
  end
end

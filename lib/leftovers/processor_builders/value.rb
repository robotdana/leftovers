# frozen_string_literal: true

require_relative '../method_processors/value'

module Leftovers
  module ProcessorBuilders
    module Value
      def self.build(value, then_processor)
        return unless value && then_processor

        ::Leftovers::MethodProcessors::Value.new(value, then_processor)
      end
    end
  end
end

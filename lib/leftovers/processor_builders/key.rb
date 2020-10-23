# frozen_string_literal: true

require_relative '../value_processors/each_key'

module Leftovers
  module ProcessorBuilders
    module Key
      def self.build(value, then_processor)
        return unless value && then_processor

        ::Leftovers::ValueProcessors::EachKey.new(then_processor)
      end
    end
  end
end

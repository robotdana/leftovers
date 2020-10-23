# frozen_string_literal: true

require_relative '../value_processors/replace_value'

module Leftovers
  module ProcessorBuilders
    module Value
      def self.build(value, then_processor)
        return unless value && then_processor

        ::Leftovers::ValueProcessors::ReplaceValue.new(value, then_processor)
      end
    end
  end
end

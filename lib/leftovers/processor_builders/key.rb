# frozen_string_literal: true

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

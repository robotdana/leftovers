# frozen_string_literal: true

module Leftovers
  module ProcessorBuilders
    module Itself
      def self.build(value, then_processor)
        return unless value && then_processor

        ::Leftovers::ValueProcessors::Itself.new(then_processor)
      end
    end
  end
end

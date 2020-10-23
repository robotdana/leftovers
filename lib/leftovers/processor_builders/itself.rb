# frozen_string_literal: true

require_relative '../method_processors/itself'

module Leftovers
  module ProcessorBuilders
    module Itself
      def self.build(value, then_processor)
        return unless value && then_processor

        ::Leftovers::MethodProcessors::Itself.new(then_processor)
      end
    end
  end
end

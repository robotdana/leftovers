# frozen_string_literal: true

module Leftovers
  module ProcessorBuilders
    module Receiver
      def self.build(value, then_processor)
        return unless value

        Processors::Receiver.new(then_processor)
      end
    end
  end
end

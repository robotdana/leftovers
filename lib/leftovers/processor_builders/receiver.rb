# frozen_string_literal: true

module Leftovers
  module ProcessorBuilders
    module Receiver
      def self.build(true_arg, then_processor)
        Processors::Receiver.new(then_processor) if true_arg
      end
    end
  end
end

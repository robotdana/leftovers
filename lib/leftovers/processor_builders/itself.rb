# frozen_string_literal: true

module Leftovers
  module ProcessorBuilders
    module Itself
      def self.build(true_arg, then_processor)
        Processors::Itself.new(then_processor) if true_arg
      end
    end
  end
end

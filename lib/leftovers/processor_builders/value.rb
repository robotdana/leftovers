# frozen_string_literal: true

module Leftovers
  module ProcessorBuilders
    module Value
      def self.build(values, then_processor)
        Each.each_or_self(values) do |value|
          Processors::ReplaceValue.new(value, then_processor)
        end
      end
    end
  end
end

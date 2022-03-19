# frozen_string_literal: true

module Leftovers
  module Processors
    class Deconstantize
      include ComparableInstance

      def initialize(then_processor)
        @then_processor = then_processor

        freeze
      end

      def process(str, current_node, matched_node, acc)
        return unless str

        @then_processor.process(str.deconstantize, current_node, matched_node, acc)
      rescue ::NoMethodError
        ::Leftovers.error <<~MESSAGE
          Tried using the ::String#deconstantize method, but the activesupport gem was not available and/or not required
          `gem install activesupport`, and/or add `requires: ['active_support', 'active_support/core_ext/string']` to your .leftovers.yml
        MESSAGE
      end

      freeze
    end
  end
end

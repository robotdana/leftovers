# frozen_string_literal: true

module Leftovers
  module ValueProcessors
    class Singularize
      def initialize(then_processor)
        @then_processor = then_processor

        freeze
      end

      def process(str, node, method_node)
        return unless str

        @then_processor.process(str.singularize, node, method_node)
      rescue NoMethodError
        Leftovers.error <<~MESSAGE
          Tried using the String#singularize method, but the activesupport gem was not available and/or not required
          `gem install activesupport`, and/or add `requires: 'active_support/core_ext/string'` to your .leftovers.yml
        MESSAGE
      end
    end
  end
end

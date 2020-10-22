# frozen_string_literal: true

module Leftovers
  module ValueProcessors
    class DeleteSuffix
      # :nocov:
      using ::Leftovers::StringDeletePrefixSuffix if defined?(::Leftovers::StringDeletePrefixSuffix)
      # :nocov:

      def initialize(suffix, then_processor)
        @suffix = suffix
        @then_processor = then_processor
      end

      def process(str, node, method_node)
        @then_processor.process(str.delete_suffix(@suffix), node, method_node)
      end
    end
  end
end

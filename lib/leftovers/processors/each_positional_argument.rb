# frozen_string_literal: true

module Leftovers
  module Processors
    class EachPositionalArgument
      include ComparableInstance

      def initialize(then_processor)
        @then_processor = then_processor

        freeze
      end

      def process(_str, current_node, matched_node, acc)
        positional_arguments = current_node.positional_arguments

        return unless positional_arguments

        positional_arguments.each do |argument_node|
          @then_processor.process(argument_node.to_literal_s, argument_node, matched_node, acc)
        end
      end

      freeze
    end
  end
end

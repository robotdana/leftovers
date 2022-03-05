# frozen_string_literal: true

module Leftovers
  module Processors
    class EachPositionalArgument
      include ComparableInstance

      def initialize(then_processor)
        @then_processor = then_processor

        freeze
      end

      def process(_str, node, method_node, acc)
        positional_arguments = node.positional_arguments

        return unless positional_arguments

        positional_arguments.each do |argument_node|
          @then_processor.process(argument_node.to_literal_s, argument_node, method_node, acc)
        end
      end

      freeze
    end
  end
end

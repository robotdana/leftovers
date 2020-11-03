# frozen_string_literal: true

module Leftovers
  module Matchers
    class NodeHasPositionalArgument
      # :nocov:
      using ::Leftovers::Backports::SetCaseEq if defined?(::Leftovers::Backports::SetCaseEq)
      # :nocov:

      def initialize(position)
        @position = position

        freeze
      end

      def ===(node)
        node.positional_arguments[@position]
      end

      freeze
    end
  end
end

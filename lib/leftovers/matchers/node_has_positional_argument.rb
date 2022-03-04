# frozen_string_literal: true

module Leftovers
  module Matchers
    class NodeHasPositionalArgument
      include ComparableInstance

      def initialize(position)
        @position = position

        freeze
      end

      def ===(node)
        args = node.positional_arguments

        args.length > @position if args
      end

      freeze
    end
  end
end

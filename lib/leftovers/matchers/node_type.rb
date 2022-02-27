# frozen_string_literal: true

module Leftovers
  module Matchers
    class NodeType
      attr_reader :matcher

      def initialize(matcher)
        @matcher = matcher

        freeze
      end

      def ===(node)
        @matcher === node.type
      end

      freeze
    end
  end
end

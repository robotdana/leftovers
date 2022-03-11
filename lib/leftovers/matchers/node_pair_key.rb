# frozen_string_literal: true

module Leftovers
  module Matchers
    class NodePairKey
      include ComparableInstance

      attr_reader :matcher

      def initialize(matcher)
        @matcher = matcher

        freeze
      end

      def ===(node)
        @matcher === node.first
      end

      freeze
    end
  end
end

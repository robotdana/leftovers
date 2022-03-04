# frozen_string_literal: true

module Leftovers
  module Matchers
    class NodeName
      include ComparableInstance

      attr_reader :matcher

      def initialize(matcher)
        @matcher = matcher

        freeze
      end

      def ===(node)
        name = node.name

        @matcher === name if name
      end

      freeze
    end
  end
end

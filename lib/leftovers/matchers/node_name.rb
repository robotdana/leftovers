# frozen_string_literal: true

module Leftovers
  module Matchers
    class NodeName
      attr_reader :matcher

      def initialize(matcher)
        @matcher = matcher

        freeze
      end

      def ===(node)
        @matcher === node.name
      end

      freeze
    end
  end
end

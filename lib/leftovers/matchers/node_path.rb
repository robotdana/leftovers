# frozen_string_literal: true

module Leftovers
  module Matchers
    class NodePath
      attr_reader :matcher

      def initialize(matcher)
        @matcher = matcher

        freeze
      end

      def ===(node)
        @matcher === node.path
      end

      freeze
    end
  end
end

# frozen_string_literal: true

module Leftovers
  module Matchers
    class NodePrivacy
      attr_reader :matcher

      def initialize(matcher)
        @matcher = matcher

        freeze
      end

      def ===(node)
        @matcher === node.privacy
      end

      freeze
    end
  end
end

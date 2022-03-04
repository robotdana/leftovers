# frozen_string_literal: true

module Leftovers
  module Matchers
    class NodeHasReceiver
      include ComparableInstance

      attr_reader :matcher

      def initialize(matcher)
        @matcher = matcher

        freeze
      end

      def ===(node)
        receiver = node.receiver
        @matcher === receiver if receiver
      end

      freeze
    end
  end
end

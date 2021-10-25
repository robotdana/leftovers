# frozen_string_literal: true

module Leftovers
  module Matchers
    class NodeHasReceiver
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

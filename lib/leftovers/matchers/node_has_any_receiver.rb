# frozen_string_literal: true

module Leftovers
  module Matchers
    module NodeHasAnyReceiver
      def self.===(node)
        node.receiver
      end

      freeze
    end
  end
end

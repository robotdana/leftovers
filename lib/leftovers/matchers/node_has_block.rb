# frozen_string_literal: true

module Leftovers
  module Matchers
    module NodeHasBlock
      def self.===(node)
        node.block_given?
      end

      freeze
    end
  end
end

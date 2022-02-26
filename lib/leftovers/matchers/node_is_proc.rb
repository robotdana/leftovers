# frozen_string_literal: true

module Leftovers
  module Matchers
    module NodeIsProc
      def self.===(node)
        node.proc?
      end

      freeze
    end
  end
end

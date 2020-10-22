# frozen_string_literal: true

module Leftovers
  module ValueProcessors
    module ReturnCall
      def self.process(str, _node, _method_node)
        return nil if str.empty?

        str.to_sym
      end
    end
  end
end

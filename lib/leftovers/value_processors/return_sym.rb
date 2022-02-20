# frozen_string_literal: true

module Leftovers
  module ValueProcessors
    module ReturnSym
      def self.process(str, _node, _method_node)
        return unless str
        return if str.empty?

        str.to_sym
      end
    end
  end
end

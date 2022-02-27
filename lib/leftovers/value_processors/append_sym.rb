# frozen_string_literal: true

module Leftovers
  module ValueProcessors
    module AppendSym
      def self.process(str, _node, _method_node, acc)
        return unless str

        acc << str.to_sym
      end
    end
  end
end

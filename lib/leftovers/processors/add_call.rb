# frozen_string_literal: true

module Leftovers
  module Processors
    module AddCall
      def self.process(str, _node, _method_node, acc)
        return unless str
        return if str.empty?

        acc.calls << str.to_sym
      end
    end
  end
end

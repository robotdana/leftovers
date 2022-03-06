# frozen_string_literal: true

module Leftovers
  module Processors
    module AddCall
      def self.process(str, _current_node, _matched_node, acc)
        return unless str
        return if str.empty?

        acc.calls << str.to_sym
      end
    end
  end
end

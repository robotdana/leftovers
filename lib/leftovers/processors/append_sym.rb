# frozen_string_literal: true

module Leftovers
  module Processors
    module AppendSym
      def self.process(str, _current_node, _matched_node, acc)
        return unless str

        acc << str.to_sym
      end
    end
  end
end

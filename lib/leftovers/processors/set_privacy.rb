# frozen-string-literal: true

module Leftovers
  module Processors
    class SetPrivacy
      include ComparableInstance

      def initialize(to)
        @to = to

        freeze
      end

      def process(str, _current_node, _matched_node, acc)
        return unless str

        acc.set_privacy(str.to_sym, @to)
      end

      freeze
    end
  end
end

# frozen-string-literal: true

module Leftovers
  module ValueProcessors
    class SetPrivacy
      def initialize(to)
        @to = to

        freeze
      end

      def process(str, _node, _method_node, acc)
        return unless str

        acc.set_privacy(str.to_sym, @to)
      end

      freeze
    end
  end
end

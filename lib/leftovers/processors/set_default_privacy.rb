# frozen-string-literal: true

module Leftovers
  module Processors
    class SetDefaultPrivacy
      include ComparableInstance

      def initialize(to)
        @to = to

        freeze
      end

      def process(_str, _node, _method_node, acc)
        acc.default_method_privacy = @to
      end

      freeze
    end
  end
end

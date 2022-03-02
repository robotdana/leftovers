# frozen-string-literal: true

module Leftovers
  module Processors
    module Eval
      def self.process(str, node, _method_node, acc)
        return unless str
        return if str.empty?

        acc.collect_subfile(str, node.loc.expression)
      end

      freeze
    end
  end
end

# frozen-string-literal: true

module Leftovers
  module ValueProcessors
    module ReturnDefinitionNode
      def self.process(str, node, _method_node)
        return unless str
        return if str.empty?

        Leftovers::DefinitionNode.new(node, name: str.to_sym)
      end
    end
  end
end

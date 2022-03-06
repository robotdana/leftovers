# frozen-string-literal: true

module Leftovers
  module Processors
    module AddDefinitionNode
      def self.process(str, current_node, _matched_node, acc)
        return unless str
        return if str.empty?

        acc.add_definition_node Leftovers::DefinitionNode.new(current_node, name: str.to_sym)
      end

      freeze
    end
  end
end

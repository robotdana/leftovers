# frozen-string-literal: true

module Leftovers
  module ValueProcessors
    module ReturnDefinition
      def self.process(str, node, method_node)
        return unless str
        return if str.empty?

        definition = Leftovers::Definition.new(
          str.to_sym,
          location: node.loc.expression,
          method_node: method_node
        )

        return :keep if ::Leftovers.config.keep === definition

        definition
      end
    end
  end
end

# frozen-string-literal: true

module Leftovers
  module ValueProcessors
    module ReturnDefinition
      # :nocov:
      using ::Leftovers::Backports::SetCaseEq if defined?(::Leftovers::Backports::SetCaseEq)
      # :nocov:

      def self.process(str, node, method_node)
        return unless str
        return if str.empty?

        str_node = Leftovers::DefinitionNode.new(str.to_sym, method_node.path)

        return :keep if ::Leftovers.config.keep === str_node

        Leftovers::Definition.new(
          str_node.name,
          location: node.loc.expression,
          test: method_node.test_line? || ::Leftovers.config.test_only === str_node
        )
      end
    end
  end
end

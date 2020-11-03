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

        return :keep if ::Leftovers.config.keep === node

        Leftovers::Definition.new(
          str.to_sym,
          location: node.loc.expression,
          method_node: method_node
        )
      end
    end
  end
end

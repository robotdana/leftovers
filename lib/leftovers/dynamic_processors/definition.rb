# frozen-string-literal: true

module Leftovers
  module DynamicProcessors
    class Definition
      def initialize(matcher, processor)
        @matcher = matcher
        @processor = processor
      end

      def process(node, file)
        return if node.keep_line?
        return unless @matcher === node

        definitions = @processor.process(nil, node, node)

        ::Leftovers.each_or_self(definitions) do |definition|
          if definition.is_a?(DefinitionNodeSet)
            file.add_definition_set(definition)
          else
            file.add_definition(definition, loc: definition.loc)
          end
        end
      end
    end
  end
end

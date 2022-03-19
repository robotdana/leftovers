# frozen-string-literal: true

module Leftovers
  class DefinitionToAdd
    attr_reader :node, :name, :location

    def initialize(node, name: node.name, location: node.loc.name)
      @node = node
      @name = name
      @location = location
    end

    def privacy=(value)
      @node.privacy = value
    end

    def keep?(file_collector)
      @keep ||= file_collector.keep_line?(location.line) || ::Leftovers.config.keep === node
    end

    def test?(file_collector)
      file_collector.test_line?(location.line) || ::Leftovers.config.test_only === node
    end

    def to_definition(file_collector)
      return if keep?(file_collector)

      Definition.new(name, location: location, test: test?(file_collector))
    end
  end
end

# frozen_string_literal: true

module Leftovers
  class ConfigLoader
    class StringSchema < Schema
      class << self
        def validate(node)
          error(node, 'be a string') unless node.string?
          super
        end
      end
    end
  end
end

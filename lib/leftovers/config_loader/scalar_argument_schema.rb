# frozen_string_literal: true

module Leftovers
  class ConfigLoader
    class ScalarArgumentSchema < Schema
      class << self
        def validate(node)
          error(node, 'be a string or an integer') unless node.string? || node.integer?
          super
        end
      end
    end
  end
end

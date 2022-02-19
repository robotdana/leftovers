# frozen_string_literal: true

module Leftovers
  class ConfigLoader
    class ScalarValueSchema < Schema
      class << self
        def validate(node)
          error(node, 'be any scalar value') unless node.scalar?
          super
        end
      end
    end
  end
end

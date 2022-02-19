# frozen_string_literal: true

module Leftovers
  class ConfigLoader
    class TrueSchema < Schema
      class << self
        def validate(node)
          error(node, 'be true') unless to_ruby(node)
          super
        end

        def to_ruby(node)
          node.to_ruby == true || node.to_ruby == 'true'
        end
      end
    end
  end
end

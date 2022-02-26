# frozen_string_literal: true

module Leftovers
  class ConfigLoader
    class Schema
      class << self
        def error(node, requirement)
          node.error = "#{node.name_}must #{requirement}"

          false
        end

        def validate(node)
          node.valid?
        end

        def to_ruby(node)
          node.to_ruby
        end
      end
    end
  end
end

# frozen_string_literal: true

module Leftovers
  class ConfigLoader
    class RegexpSchema < StringSchema
      class << self
        def validate(node)
          validate_string(node) && validate_regexp(node)
        end

        def validate_string(node)
          error(node, 'be a string with a valid ruby regexp') unless node.string?

          node.valid?
        end

        def validate_regexp(node)
          /#{node.to_ruby}/
        rescue RegexpError, ArgumentError => e
          error(node, "be a string with a valid ruby regexp (#{e.message})")
        else
          true
        end
      end
    end
  end
end

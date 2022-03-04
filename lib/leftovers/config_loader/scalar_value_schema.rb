# frozen_string_literal: true

module Leftovers
  class ConfigLoader
    class ScalarValueSchema < Schema
      class << self
        def validate(node)
          error(node, 'be any scalar value') unless node.scalar?
          super
        end

        def to_ruby(node)
          if node.to_ruby.nil?
            :_leftovers_nil_value
          else
            node.to_ruby
          end
        end
      end
    end
  end
end

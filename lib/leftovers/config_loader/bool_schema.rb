# frozen_string_literal: true

module Leftovers
  class ConfigLoader
    class BoolSchema < Schema
      class << self
        def validate(node)
          error(node, 'be true or false') if to_ruby(node).nil?
          super
        end

        def to_ruby(node)
          case node.to_ruby
          when true, 'true' then true
          when false, 'false' then false
          end
        end
      end
    end
  end
end

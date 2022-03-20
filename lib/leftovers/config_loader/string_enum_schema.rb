# frozen_string_literal: true

module Leftovers
  class ConfigLoader
    class StringEnumSchema < Schema
      class << self
        def value(value, aliases: nil)
          values << value
          Array(aliases).each do |alias_name|
            self.aliases[alias_name] = value
          end
        end

        def aliases
          @aliases ||= {}
        end

        def aliases_for(value)
          aliases.select { |_k, v| v == value }.keys
        end

        def values
          @values ||= []
        end

        def each_value(&block)
          @values.each(&block)
        end

        def to_ruby(node)
          aliases[node.to_sym] || node.to_sym
        end

        def validate(node)
          if node.string?
            node.error = error_message_with_suggestions(node) unless valid_value?(node.to_sym)
          else
            error(node, 'be a string')
          end

          super
        end

        private

        def valid_value?(val)
          values.include?(val) || aliases.key?(val)
        end

        def suggester
          @suggester ||= Suggester.new(values)
        end

        def error_message_with_suggestions(node)
          suggestions = suggester.suggest(node.to_ruby)

          "unrecognized value #{node} for #{node.name}\nDid you mean: #{suggestions.join(', ')}"
        end
      end
    end
  end
end

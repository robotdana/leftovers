# frozen_string_literal: true

require 'json'

module Leftovers
  module JSON
    class << self
      def precompile(json, name)
        "__leftovers_document(#{to_ruby_argument(::JSON.parse(json))})"
      rescue ::JSON::ParserError => e
        Leftovers.warn "#{e.class}: (#{name.relative_path}): #{e.message}"
        ''
      end

      private

      def to_ruby_argument(value)
        ruby = value.inspect
        return ruby unless value.is_a?(Array)

        ruby.delete_prefix!('[')
        ruby.delete_suffix!(']')

        ruby
      end
    end
  end
end

# frozen_string_literal: true

require 'json'

module Leftovers
  module Precompilers
    module JSON
      class << self
        def precompile(json)
          "__leftovers_document(#{to_ruby_argument(::JSON.parse(json))})"
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
end

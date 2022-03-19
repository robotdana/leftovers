# frozen_string_literal: true

require 'yaml'

module Leftovers
  module Precompilers
    module YAML
      include Autoloader

      def self.precompile(yaml)
        builder = Builder.new
        parser = ::Psych::Parser.new(builder)
        parser.parse(yaml)

        builder.to_ruby_file
      rescue ::Psych::SyntaxError => e
        message = [e.problem, e.context].compact.join(' ')
        raise PrecompileError.new(message, line: e.line, column: e.column)
      end
    end
  end
end

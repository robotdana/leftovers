# frozen_string_literal: true

require 'slim'

module Leftovers
  module Precompilers
    module Slim
      def self.precompile(file)
        ::Slim::Engine.new(file: file).call(file)
      rescue ::Slim::Parser::SyntaxError => e
        raise PrecompileError.new(e.error, line: e.lineno, column: e.column)
      end
    end
  end
end

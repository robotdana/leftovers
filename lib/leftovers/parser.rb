# frozen_string_literal: true

require 'parser'
require 'parser/current'

require_relative 'ast/builder'
require_relative 'ast/node'

module Leftovers
  module Parser
    class << self
      # mostly copied from https://github.com/whitequark/parser/blob/master/lib/parser/base.rb
      # but with our parser
      def parse_with_comments(string, file = '(string)', line = 1)
        PARSER.reset
        source_buffer = ::Parser::CurrentRuby.send(
          :setup_source_buffer, file, line, string, PARSER.default_encoding
        )
        PARSER.parse_with_comments(source_buffer)
      end

      private

      # mostly copied from https://github.com/whitequark/parser/blob/master/lib/parser/base.rb
      # but with our builder
      def parser # rubocop:disable Metrics/MethodLength
        p = ::Parser::CurrentRuby.new(Leftovers::AST::Builder.new)
        p.diagnostics.all_errors_are_fatal = true
        p.diagnostics.ignore_warnings = true

        p.diagnostics.consumer = lambda do |diagnostic|
          warn(diagnostic.render)
        end

        p
      end
    end
    PARSER = parser
  end
end

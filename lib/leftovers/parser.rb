# frozen_string_literal: true

require 'parser'
require 'parser/current'

module Leftovers
  module Parser
    class << self
      # mostly copied from https://github.com/whitequark/parser/blob/master/lib/parser/base.rb
      # but with our parser
      def parse_with_comments(string, file = '(string)', line = 1)
        PARSER.reset
        PARSER.parse_with_comments(new_source_buffer(string, file, line))
      end

      private

      def new_source_buffer(string, file, line)
        ::Parser::CurrentRuby.send(
          :setup_source_buffer, file, line, string, PARSER.default_encoding
        )
      end

      # mostly copied from https://github.com/whitequark/parser/blob/master/lib/parser/base.rb
      # but with our builder
      def parser
        p = ::Parser::CurrentRuby.new(AST::Builder.new)
        p.diagnostics.all_errors_are_fatal = true
        p.diagnostics.ignore_warnings = true

        p.diagnostics.consumer = lambda do |diagnostic|
          diagnostic
        end

        p
      end
    end
    PARSER = parser
  end
end

# frozen_string_literal: true

require 'yaml'

module Leftovers
  module YAML
    class Builder < ::Psych::TreeBuilder
      def initialize
        @constants = []

        super
      end

      def add_constant_for_tag(tag, value = nil)
        match = %r{\A!ruby/[^:]*(?::(.*))?\z}.match(tag)
        return unless match

        @constants << (match[1] || value)
      end

      def start_mapping(_anchor, tag, *rest) # leftovers:keep
        add_constant_for_tag(tag)
        tag = nil

        super
      end

      def start_sequence(_anchor, tag, *rest) # leftovers:keep
        add_constant_for_tag(tag)
        tag = nil

        super
      end

      def scalar(value, _anchor, tag, *rest) # leftovers:keep
        add_constant_for_tag(tag, value)
        tag = nil

        super
      end

      def to_ruby_file
        [
          '_leftovers_yaml_document(',
          root.to_ruby.first.inspect,
          ')',
          *@constants
        ].join("\n")
      end
    end

    def self.precompile(yaml, name)
      handler = ::Leftovers::YAML::Builder.new
      parser = ::Psych::Parser.new(handler)
      parser.parse(yaml, name.relative_path)

      handler.to_ruby_file
    rescue ::Psych::SyntaxError => e
      Leftovers.warn "#{e.class}: #{e.message}"
      ''
    end
  end
end

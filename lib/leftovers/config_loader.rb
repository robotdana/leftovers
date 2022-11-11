# frozen_string_literal: true

require 'yaml'

module Leftovers
  class ConfigLoader
    include Autoloader

    def self.load(name, path: nil, content: nil)
      new(name, path: path, content: content).load
    end

    attr_reader :name

    def initialize(name, path: nil, content: nil)
      @name = name
      @path = path
      @content = content
    end

    def load
      document = Node.new(parse, file)
      DocumentSchema.validate(document)

      all_errors = document.all_errors
      return DocumentSchema.to_ruby(document) if all_errors.empty?

      ::Leftovers.error(all_errors.join("\n"))
    end

    private

    def path
      @path ||= ::File.expand_path("../config/#{name}.yml", __dir__)
    end

    def file
      @file ||= File.new(path)
    end

    def content
      @content ||= file.exist? ? file.read : ''
    end

    def parse
      parsed = ::Psych.parse(content)
      parsed ||= ::Psych.parse('{}')
      parsed.children.first
    rescue ::Psych::SyntaxError => e
      message = [e.problem, e.context].compact.join(' ')
      ::Leftovers.error "Config SyntaxError: #{file.relative_path}:#{e.line}:#{e.column} #{message}"
    end
  end
end

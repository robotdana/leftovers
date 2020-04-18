# frozen_string_literal: true

require 'yaml'
require_relative 'rule'

module Leftovers
  class Config
    # :nocov:
    using ::Leftovers::YAMLSymbolizeNames if defined?(::Leftovers::YAMLSymbolizeNames)
    # :nocov:

    attr_reader :name

    def initialize(
      name,
      path: ::File.join(__dir__, '..', 'config', "#{name}.yml"),
      content: (::File.exist?(path) ? ::File.read(path) : '')
    )
      @name = name.to_sym
      @path = path
      @content = content
    end

    def gems
      @gems ||= Array(yaml[:gems]).map(&:to_sym)
    end

    def exclude_paths
      @exclude_paths ||= Array(yaml[:exclude_paths])
    end

    def include_paths
      @include_paths ||= Array(yaml[:include_paths])
    end

    def test_paths
      @test_paths ||= Array(yaml[:test_paths])
    end

    def rules
      @rules ||= Rule.wrap(yaml[:rules])
    end

    private

    def yaml
      @yaml ||= YAML.safe_load(@content, symbolize_names: true) || {}
    rescue Psych::SyntaxError => e
      warn "\e[31mError with config #{path}: #{e.message}\e[0m"
      exit 1
    end
  end
end

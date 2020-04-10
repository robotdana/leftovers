# frozen_string_literal: true

require 'yaml'
require_relative 'name_rule'
require_relative 'rule'

module Leftovers
  class Config
    def initialize(name, path: File.join(__dir__, '..', 'config', "#{name}.yml"))
      @name = name
      @path = path
    end

    def exist?
      File.exist?(path)
    end

    def gems
      @gems ||= Array(yaml[:gems])
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

    attr_reader :name, :path

    def yaml
      @yaml ||= load_yaml(path)
    end

    def load_yaml(*path)
      file = ::File.join(*path)
      return {} unless ::File.exist?(file)

      YAML.safe_load(::File.read(file), symbolize_names: true)
    rescue Psych::SyntaxError => e
      $stderr.puts "\e[31mError with config #{path}: #{e.message}\e[0m"
      exit 1
    end
  end
end

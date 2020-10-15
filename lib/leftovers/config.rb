# frozen_string_literal: true

require 'yaml'
require_relative 'rule'

module Leftovers
  class Config
    # :nocov:
    using ::Leftovers::SetCaseEq if defined?(::Leftovers::SetCaseEq)
    # :nocov:

    attr_reader :name

    def initialize(name, path: nil, content: nil)
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
    rescue Leftovers::ConfigError => e
      warn "\e[31mConfig Error: (#{path}): #{e.message}\e[0m"
      Leftovers.exit 1
    end

    def validate
      errors = ::Leftovers::ConfigValidator.validate(parse_yaml(symbolize_names: false))
      warn errors.to_s unless errors.empty?
      errors
    end

    private

    def content
      @content ||= ::File.exist?(path) ? ::File.read(path) : ''
    end

    def path
      @path ||= ::File.expand_path("../config/#{name}.yml", __dir__)
    end

    def yaml
      @yaml ||= parse_yaml
    end

    def parse_yaml(symbolize_names: true) # rubocop:disable Metrics/MethodLength
      # :nocov:
      if Gem::Version.new(RUBY_VERSION) >= Gem::Version.new('2.6')
        Psych.safe_load(content, symbolize_names: symbolize_names, filename: path) || {}
      else
        data = Psych.safe_load(content, [], [], false, path) || {}
        symbolize_names ? symbolize_names!(data) : data
      end
      # :nocov:
    rescue ::Psych::SyntaxError => e
      warn "\e[31mConfig SyntaxError: #{e.message}\e[0m"
      Leftovers.exit 1
    end

    # :nocov:
    def symbolize_names!(obj) # rubocop:disable Metrics/MethodLength
      case obj
      when Hash
        obj.keys.each do |key| # rubocop:disable Style/HashEachMethods # each_key never finishes.
          obj[key.to_sym] = symbolize_names!(obj.delete(key))
        end
      when Array
        obj.map! { |ea| symbolize_names!(ea) }
      end
      obj
    end
    # :nocov:
  end
end

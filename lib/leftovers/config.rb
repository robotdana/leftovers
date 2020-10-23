# frozen_string_literal: true

require 'yaml'

module Leftovers
  class Config
    # :nocov:
    using ::Leftovers::Backports::SetCaseEq if defined?(::Leftovers::Backports::SetCaseEq)
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
      @rules ||= ::Leftovers::ProcessorBuilders::Rule.build(yaml[:rules])
    rescue Leftovers::ConfigError => e
      warn "\e[31mConfig Error: (#{path}): #{e.message}\e[0m"
      Leftovers.exit 1
    end

    def keep
      @keep ||= ::Leftovers::MatcherBuilders::Keep.build(yaml[:keep])
    rescue Leftovers::ConfigError => e
      warn "\e[31mConfig Error: (#{path}): #{e.message}\e[0m"
      Leftovers.exit 1
    end

    private

    def content
      @content ||= ::File.exist?(path) ? ::File.read(path) : ''
    end

    def path
      @path ||= ::File.expand_path("../config/#{name}.yml", __dir__)
    end

    def yaml
      @yaml ||= ::Leftovers::ConfigValidator.validate_and_process!(parse_yaml, path)
    end

    def parse_yaml
      # :nocov:
      if Gem::Version.new(RUBY_VERSION) >= Gem::Version.new('2.6')
        Psych.safe_load(content, filename: path) || {}
      else
        Psych.safe_load(content, [], [], false, path) || {}
      end
      # :nocov:
    rescue ::Psych::SyntaxError => e
      warn "\e[31mConfig SyntaxError: #{e.message}\e[0m"
      Leftovers.exit 1
    end
  end
end

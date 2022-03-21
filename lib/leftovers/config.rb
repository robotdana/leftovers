# frozen_string_literal: true

module Leftovers
  class Config
    attr_reader :name
    alias_method :to_sym, :name

    def self.[](name_or_config)
      return name_or_config if name_or_config.is_a?(self)

      @loaded_configs ||= {}
      @loaded_configs[name_or_config] ||= new(name_or_config)
    end

    def self.reset
      @loaded_configs = {}
    end

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

    def precompile
      @precompile ||= ::Leftovers.wrap_array(yaml[:precompile])
    end

    def dynamic
      @dynamic ||= ProcessorBuilders::Dynamic.build(yaml[:dynamic])
    end

    def keep
      @keep ||= MatcherBuilders::Node.build(yaml[:keep])
    end

    def test_only
      @test_only ||= MatcherBuilders::Node.build(yaml[:test_only])
    end

    def requires
      @requires ||= Array(yaml[:requires])
    end

    private

    def yaml
      @yaml ||= ConfigLoader.load(name, path: @path, content: @content)
    end
  end
end

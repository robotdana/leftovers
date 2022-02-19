# frozen_string_literal: true

module Leftovers
  class Config
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

    def haml_paths
      @haml_paths ||= Array(yaml[:haml_paths])
    end

    def slim_paths
      @slim_paths ||= Array(yaml[:slim_paths])
    end

    def yaml_paths
      @yaml_paths ||= Array(yaml[:yaml_paths])
    end

    def json_paths
      @json_paths ||= Array(yaml[:json_paths])
    end

    def erb_paths
      @erb_paths ||= Array(yaml[:erb_paths])
    end

    def dynamic
      @dynamic ||= ::Leftovers::ProcessorBuilders::Dynamic.build(yaml[:dynamic])
    end

    def keep
      @keep ||= ::Leftovers::MatcherBuilders::Node.build(yaml[:keep])
    end

    def test_only
      @test_only ||= ::Leftovers::MatcherBuilders::Node.build(yaml[:test_only])
    end

    def requires
      @requires ||= Array(yaml[:requires])
    end

    private

    def yaml
      @yaml ||= ::Leftovers::ConfigLoader.load(name, path: @path, content: @content)
    end
  end
end

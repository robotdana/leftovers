# frozen_string_literal: true

require 'set'
require 'fast_ignore'

module Leftovers
  class MergedConfig
    def initialize
      @configs = []
      @loaded_configs = Set.new
      self << :ruby
      self << project_config
      load_bundled_gem_config
    end

    def <<(config)
      config = Leftovers::Config.new(config) unless config.is_a?(Leftovers::Config)
      return if @loaded_configs.include?(config.name)

      unmemoize
      @configs << config
      @loaded_configs << config.name
      config.gems.each { |gem| self << gem }
    end

    def project_config
      Leftovers::Config.new(:'.leftovers.yml', path: Leftovers.pwd + '.leftovers.yml')
    end

    def unmemoize
      remove_instance_variable(:@exclude_paths) if defined?(@exclude_paths)
      remove_instance_variable(:@include_paths) if defined?(@include_paths)
      remove_instance_variable(:@test_paths) if defined?(@test_paths)
      remove_instance_variable(:@rules) if defined?(@rules)
      remove_instance_variable(:@keep) if defined?(@keep)
    end

    def exclude_paths
      @exclude_paths ||= @configs.flat_map(&:exclude_paths)
    end

    def include_paths
      @include_paths ||= @configs.flat_map(&:include_paths)
    end

    def test_paths
      @test_paths ||= FastIgnore.new(
        include_rules: @configs.flat_map(&:test_paths),
        gitignore: false,
        root: Leftovers.pwd
      )
    end

    def rules
      @rules ||= ::Leftovers::ProcessorBuilders::EachRule.build(@configs.map(&:rules))
    end

    def keep
      @keep ||= ::Leftovers::MatcherBuilders::Or.build(@configs.map(&:keep))
    end

    private

    def load_bundled_gem_config
      return unless Leftovers.try_require('bundler')

      Bundler.locked_gems.specs.each do |spec|
        self << spec.name
      end
    end
  end
end

require 'set'
require_relative 'config'
require 'fast_ignore'

module Leftovers
  class MergedConfig
    def initialize
      @configs = []
      @configs << Leftovers::Config.new('ruby')
      @configs << Leftovers::Config.new('project', path: File.join(Dir.pwd, '.leftovers.yml'))
      gem_config_loaded = Set.new
      gem_config_to_load = @configs.flat_map(&:gems)

      until gem_config_to_load.empty?
        gem = gem_config_to_load.pop
        next if gem_config_loaded.include?(gem)
        gem_config = Leftovers::Config.new(gem)
        if gem_config.exist?
          @configs << gem_config
          gem_config_loaded << gem
          gem_config_to_load += gem_config.gems
        end
      end
    end

    def exclude_paths
      @exclude_paths ||= @configs.flat_map(&:exclude_paths)
    end

    def include_paths
      @include_paths ||= @configs.flat_map(&:include_paths)
    end

    def test_paths
      @test_paths ||= FastIgnore.new(include_rules: @configs.flat_map(&:test_paths), gitignore: false)
    end

    def skip_rules
      @skip_rules ||= rules.select(&:skip?)
    end

    def rules
      @rules ||= @configs.flat_map(&:rules)
    end
  end
end

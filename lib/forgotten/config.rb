# frozen_string_literal: true

require 'yaml'

module Forgotten
  class Config
    def initialize
      default_config = load_yaml(__dir__, '..', 'config', 'default.yml')
      project_config = load_yaml(Dir.pwd, '.forgotten.yml')

      @config = merge_config(default_config, project_config)
      @config = merge_config(@config, load_yaml(__dir__, '..', 'config', 'rails.yml')) if rails?
      @config = merge_config(@config, load_yaml(__dir__, '..', 'config', 'rspec.yml')) if rspec?
      @config = merge_config(@config, load_yaml(__dir__, '..', 'config', 'redcarpet.yml')) if redcarpet?
    end

    def excludes
      @config[:excludes]
    end

    def includes
      @config[:includes]
    end

    def rails?
      @config[:rails]
    end

    def rspec?
      @config[:rspec]
    end

    def redcarpet?
      @config[:redcarpet]
    end

    def rules
      @rules ||= MethodRule.wrap(@config[:rules])
    end

    def allowed
      @allowed ||= Array(@config[:allowed]).map do |pattern|
        # * becomes .*, everything else is rendered inert for regexps. Also it's anchored
        Regexp.new("\\A#{Regexp.escape(pattern).gsub('\\*', '.*')}\\z")
      end
    end

    private

    def load_yaml(*path)
      file = ::File.join(*path)
      return {} unless ::File.exist?(file)

      YAML.safe_load(::File.read(file), symbolize_names: true)
    end

    def merge_config(default, project)
      if project.is_a?(Array) && default.is_a?(Array)
        default | project
      elsif project.is_a?(Hash) && default.is_a?(Hash)
        default.merge(project) { |_k, d, p| merge_config(d, p) }
      else
        project
      end
    end
  end
end

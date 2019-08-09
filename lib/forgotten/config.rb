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
    end

    def ignored
      @config[:ignore]
    end

    def only
      @config[:only]
    end

    def rails?
      @config[:rails]
    end

    def rspec?
      @config[:rspec]
    end

    def method_callers
      @method_callers ||= Matcher.wrap(@config[:method_callers])
    end

    def method_list_callers
      @method_list_callers ||= Matcher.wrap(@config[:method_list_callers])
    end

    def symbol_key_callers
      @symbol_key_callers ||= Matcher.wrap(@config[:symbol_key_callers])
    end

    def symbol_key_list_callers
      @symbol_key_list_callers ||= Matcher.wrap(@config[:symbol_key_list_callers])
    end

    def alias_method_callers
      @alias_method_callers ||= Matcher.wrap(@config[:alias_method_callers])
    end

    def method_hash_key_callers
      @method_hash_key_callers ||= Matcher.wrap(@config[:method_hash_key_callers])
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

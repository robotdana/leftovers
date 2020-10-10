# frozen_string_literal: true

require_relative 'matchers/name_builder'
require_relative 'argument_rule'
require 'fast_ignore'

module Leftovers
  class Rule
    # :nocov:
    using ::Leftovers::SetCaseEq if defined?(::Leftovers::SetCaseEq)
    # :nocov:

    def self.wrap(rules)
      case rules
      when Array then rules.flat_map { |r| wrap(r) }
      when nil then [].freeze
      else new(**rules)
      end
    end

    attr_reader :skip
    alias_method :skip?, :skip

    def initialize( # rubocop:disable Metrics/ParameterLists, Metrics/PerceivedComplexity, Metrics/MethodLength, Metrics/CyclomaticComplexity, Metrics/AbcSize
      name: nil,
      names: nil,
      calls: nil,
      call: nil,
      skip: false,
      defines: nil,
      define: nil,
      path: nil,
      paths: nil
    )
      raise Leftovers::ConfigError, 'Only use one of name/names' if name && names
      raise Leftovers::ConfigError, 'Only use one of path/paths' if path && paths
      raise Leftovers::ConfigError, 'Only use one of call/calls' if call && calls
      raise Leftovers::ConfigError, 'Only use one of define/defines' if define && defines
      if skip && (defines || calls || define || call)
        raise Leftovers::ConfigError, "skip can't exist with defines or calls"
      end

      @name_matcher = ::Leftovers::Matchers::NameBuilder.build(name || names)
      if path || paths
        @path = FastIgnore.new(include_rules: path || paths, gitignore: false, root: Leftovers.pwd)
      end
      @skip = skip

      begin
        @calls = ArgumentRule.wrap(calls)
      rescue ArgumentError, Leftovers::ConfigError => e
        raise e, "#{e.message} for calls", e.backtrace
      end

      begin
        @defines = ArgumentRule.wrap(defines, definer: true)
      rescue ArgumentError, Leftovers::ConfigError => e
        raise e, "#{e.message} for defines", e.backtrace
      end
    rescue ArgumentError, Leftovers::ConfigError => e
      raise e, "#{e.message} for #{Array(name || names).map(&:to_s).join(', ')}", e.backtrace
    end

    def filename?(file)
      return true unless @path

      @path.allowed?(file)
    end

    def match?(name, file)
      @name_matcher === name && filename?(file)
    end

    def calls(node)
      @calls.flat_map { |m| m.matches(node) }
    end

    def definitions(node)
      @defines.flat_map { |m| m.matches(node) }
    end
  end
end

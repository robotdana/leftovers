# frozen_string_literal: true

require_relative 'name_rule'
require_relative 'argument_rule'
require 'fast_ignore'

module Leftovers
  class Rule
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
      raise ArgumentError, 'Only use one of name/names' if name && names
      raise ArgumentError, 'Only use one of path/paths' if path && paths
      raise ArgumentError, 'Only use one of call/calls' if call && calls
      raise ArgumentError, 'Only use one of define/defines' if define && defines
      if skip && (defines || calls)
        raise ArgumentError, "skip can't exist with defines or calls for #{name || names}"
      end

      @name_matcher = NameRule.new(name || names)
      @path = FastIgnore.new(include_rules: path || paths, gitignore: false) if path || paths
      @skip = skip

      begin
        @calls = ArgumentRule.wrap(calls)
      rescue ArgumentError => e
        raise e, "#{e.message} for calls for #{name}", e.backtrace
      end

      begin
        @defines = ArgumentRule.wrap(defines, definer: true)
      rescue ArgumentError => e
        raise e, "#{e.message} for defines for #{name}", e.backtrace
      end
    end

    def filename?(file)
      return true unless @path

      @path.allowed?(file)
    end

    def match?(name, name_s, file)
      @name_matcher.match?(name, name_s) && filename?(file)
    end

    def calls(node)
      @calls.flat_map { |m| m.matches(node) }
    end

    def definitions(node)
      @defines.flat_map { |m| m.matches(node) }
    end
  end
end

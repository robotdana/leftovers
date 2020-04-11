require_relative 'name_rule'
require_relative 'argument_rule'
require 'fast_ignore'

module Leftovers
  class Rule
    def self.wrap(rules)
      case rules
      when Array
        rules.flat_map { |r| wrap(r) }
      when nil
        []
      else
        new(**rules)
      end
    end

    attr_reader :skip
    alias_method :skip?, :skip

    def initialize(name: nil, names: nil, calls: nil, call: nil, skip: false, defines: nil, define: nil, define_group: nil, defines_group: nil, define_groups: nil, defines_groups: nil, path: nil, paths: nil)
      raise ArgumentError, "Only use one of name/names" if name && names
      raise ArgumentError, "Only use one of path/paths" if path && paths
      raise ArgumentError, "Only use one of call/calls" if call && calls
      raise ArgumentError, "Only use one of define/defines" if define && defines
      raise ArgumentError, "Only use one of define_group/defines_group" if define_group && defines_group
      raise ArgumentError, "skip can't exist with defines or calls for #{name || names}" if skip && (defines || calls || defines_group)

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

      begin
        @defines_group = ArgumentRule.wrap(defines_group, definer: true)
      rescue ArgumentError => e
        raise e, "#{e.message} for defines_group for #{name}", e.backtrace
      end
    end

    def name?(name)
      @name_matcher.match?(name)
    end

    def filename?(filename)
      return true unless @path

      @path.allowed?(filename)
    end

    def match?(name, filename)
      name?(name) && filename?(filename)
    end

    def calls(node)
      @calls.flat_map { |m| m.matches(node) }
    end

    def definitions(node)
      defines_group = @defines_group.flat_map { |m| m.matches(node) }
      defines_group.each { |d| d.group = defines_group }
      @defines.flat_map { |m| m.matches(node) } + defines_group
    end
  end
end

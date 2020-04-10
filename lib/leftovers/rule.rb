require_relative 'name_rule'

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

    def initialize(name: nil, names: nil, calls: nil, skip: false, defines: nil, path: nil, paths: nil)
      raise ArgumentError, "Only use one of name/names" if name && names
      raise ArgumentError, "Only use one of path/paths" if path && paths
      raise ArgumentError, "skip can't exist with defines or calls for #{name || names}" if skip && (defines || calls)

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
      @defines.flat_map { |m| m.matches(node) }
    end
  end
end

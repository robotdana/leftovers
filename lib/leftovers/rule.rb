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

    def initialize(name:, caller: nil, skip: false, definer: nil, path: nil)
      raise ArgumentError, "skip can't exist with definer or caller for #{name}" if skip && (definer || caller)

      @name_matcher = NameRule.new(name)
      @path = FastIgnore.new(include_rules: path, gitignore: false) if path
      @skip = skip

      begin
        @caller = ArgumentRule.wrap(caller)
      rescue ArgumentError => e
        raise ArgumentError, "#{e.message} for caller for #{name}"
      end

      begin
        @definer = ArgumentRule.wrap(definer, definer: true)
      rescue ArgumentError => e
        raise ArgumentError, "#{e.message} for definer for #{name}"
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
      @caller.flat_map { |m| m.matches(node) }
    end

    def definitions(node)
      @definer.flat_map { |m| m.matches(node) }
    end
  end
end

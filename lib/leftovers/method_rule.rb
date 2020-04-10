require_relative 'name_rule'

module Leftovers
  class MethodRule
    def self.wrap(rules)
      case rules
      when Array
        rules.flat_map { |r| wrap(r) }
      else
        new(**rules)
      end
    end

    def initialize(name:, caller: nil, definer: nil, path: nil)
      @name_matcher = NameRule.new(name)
      @path = FastIgnore.new(include_rules: path, gitignore: false) if path

      begin
        @caller = ArgumentRule.wrap(caller)
      rescue ArgumentError => e
        raise ArgumentError, "#{e.message} for caller #{method}"
      end

      begin
        @definer = ArgumentRule.wrap(definer, definer: true)
      rescue ArgumentError => e
        raise ArgumentError, "#{e.message} for definer #{method}"
      end
    end

    def name?(node)
      @name_matcher.match?(node.name)
    end

    def filename?(filename)
      return true unless @path

      @path.allowed?(filename)
    end

    def match?(node, filename)
      name?(node) && filename?(filename)
    end

    def calls(node)
      @caller.flat_map { |m| m.matches(node) }
    end

    def definitions(node)
      @definer.flat_map { |m| m.matches(node) }
    end
  end
end

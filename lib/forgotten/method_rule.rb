require_relative 'matcher'

module Forgotten
  class MethodRule
    attr_reader :path
    attr_reader :caller
    attr_reader :definer

    def self.wrap(rules)
      case rules
      when Array
        rules.flat_map { |r| wrap(r) }
      else
        new(**rules)
      end
    end

    def initialize(method:, caller: nil, definer: nil, path: nil)
      @method_matcher = Matcher.new(method)
      @path = Array(path)
      @caller = ArgumentRule.wrap(caller)
      @definer = ArgumentRule.wrap(definer, definer: true)
    end

    def method_name?(node)
      @method_matcher.match?(node.name)
    end

    def filename?(filename)
      return true if path.empty?

      path.any? { |p| File.fnmatch?(p, filename) }
    end

    def match?(node, filename)
      method_name?(node) && filename?(filename)
    end

    def calls(node)
      caller.flat_map { |m| m.matches(node) }
    end

    def definitions(node, filename)
      definer.flat_map { |m| m.matches(node) }.each { |d| d.filename = filename }
    end
  end
end

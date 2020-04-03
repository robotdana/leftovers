module Forgotten
  class MethodRule
    attr_reader :method
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
      @method = Array(method).map(&:to_sym)
      @path = Array(path)
      @caller = ArgumentRule.wrap(caller)
      @definer = ArgumentRule.wrap(definer, definer: true)
    end

    def method_name?(node)
      method.any? { |m| File.fnmatch?(m.to_s, node.children[1].to_s) }
    end

    def filename?(filename)
      return true if path.empty?

      path.any? { |p| File.fnmatch?(p, filename) }
    end

    def calls(node, filename)
      return [] unless method_name?(node) && filename?(filename)

      caller.flat_map { |m| m.matches(node) }
    end

    def definitions(node, filename)
      return [] unless method_name?(node) && filename?(filename)

      definer.flat_map { |m| m.matches(node) }.each { |d| d.filename = filename }
    end
  end
end

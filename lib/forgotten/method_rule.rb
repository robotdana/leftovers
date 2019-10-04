module Forgotten
  class MethodRule
    attr_reader :method
    attr_reader :caller
    attr_reader :definer

    def self.wrap(rules)
      case rules
      when Array
        rules.flat_map { |r| wrap(r) }
      else
        new(rules)
      end
    end

    def initialize(method:, caller: nil, definer: nil)
      @method = Array(method).map(&:to_sym)
      @caller = ArgumentRule.wrap(caller)
      @definer = ArgumentRule.wrap(definer, definer: true)
    end

    def method_name?(node)
      method.include?(node.children[1])
    end

    def calls(node)
      return [] unless method_name?(node)

      caller.flat_map { |m| m.matches(node) }
    end

    def definitions(node)
      return [] unless method_name?(node)

      definer.flat_map { |m| m.matches(node) }
    end
  end
end

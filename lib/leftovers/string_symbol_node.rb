module Leftovers
  class StringSymbolNode
    def self.try(node)
      if node.is_a?(StringSymbolNode)
        node
      elsif [:sym, :str].include?(node&.type)
        new(node)
      end
    end

    def initialize(node)
      @node = node
    end

    def type
      :sym
    end

    SPLIT = /[.:]+/
    def parts
      to_s.split(SPLIT)
    end

    def loc
      node.loc
    end

    def value
      @value ||= node.children.first
    end
    alias_method :to_sym, :value

    def to_s
      @to_s ||= value.to_s
    end

    private

    attr_reader :node
  end
end

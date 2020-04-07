require_relative 'string_symbol_node'

module Forgotten
  class HashNode
    def self.try(node)
      if node&.type == :hash
        new(node)
      end
    end

    def initialize(node)
      @node = node
    end

    def pairs
      @pairs ||= begin
        pairs = {}
        @pairs_with_symbol_keys = {}
        node.children.each do |pair|
          key = StringSymbolNode.try(pair.children.first)
          if key
            value = pair.children[1]
            pairs[key] = value
            @pairs_with_symbol_keys[key.to_sym] = value
          end
        end
        pairs
      end
    end

    def pairs_with_symbol_keys
      return @pairs_with_symbol_keys if defined?(@pairs_with_symbol_keys)

      pairs
      @pairs_with_symbol_keys
    end

    def type
      :hash
    end

    def keys
      @keys ||= pairs.keys.to_set
    end

    def key?(key)
      pairs_with_symbol_keys.key?(key)
    end

    def value_nodes_at(keys)
      pairs_with_symbol_keys.values_at(*keys)
    end

    def value_nodes
      pairs.values
    end

    def [](key)
      value_node = pairs_with_symbol_keys[key]
      StringSymbolNode.try(value_node) || value_node&.type == :true
    end

    private

    attr_reader :node
  end
end

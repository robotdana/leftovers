module Forgotten
  class ArgumentRule
    def self.wrap(rules, definer: false)
      case rules
      when Array
        rules.flat_map { |r| wrap(r, definer: definer) }
      when Hash
        [new(**rules, definer: definer)]
      when true
        [new(definer: definer)]
      else
        []
      end
    end

    def initialize(
      position: nil,
      keyword: nil,
      array: false,
      after: nil,
      before: nil,
      prefix: nil,
      suffix: nil,
      activesupport: nil,
      rails_delegate: false,
      key: false,
      definer: false)
      @keyword = prepare_keyword(keyword)
      @position = prepare_position(position, @keyword, key)
      @rails_delegate = rails_delegate
      @array = Array(array)
      @after = after
      @before = before
      @prefix = prefix
      @suffix = suffix
      @activesupport = Array(activesupport)
      @key = key
      @definer = definer
    end

    attr_reader :position, :keyword, :array, :after, :before, :prefix, :suffix, :activesupport, :definer, :key, :rails_delegate

    def prepare_position(position, keyword, key)
      position = Array(position)
      return position if position && !position.empty?
      return ['**'] if (keyword && !keyword.empty?) || key
      ['*']
    end

    def prepare_keyword(keyword)
      Array(keyword).map { |k| k.respond_to?(:to_sym) ? k.to_sym : k }
    end

    def matches(method_node)
      position.flat_map do |n|
        case n
        when '*'
          method_node.children.drop(2).flat_map { |s| value(s, method_node) }
        when '**'
          hash(method_node.children.drop(2)[-1], method_node)
        when Integer
          value(method_node.children[n + 1], method_node)
        end
      end.compact
    end

    def hash(hash_node, method_node)
      return unless hash_node
      return unless hash_node.type == :hash

      out = if key == true
        hash_node.children.flat_map { |pair| value(pair.children.first, method_node) }
      else
        []
      end

      hash_node.children.each do |pair|
        next unless keyword_match?(pair.children.first)

        out << value(pair.children.last, method_node)
      end.compact
      out.flatten
    end

    def keyword_match?(symbol_node)
      return true if keyword.include?(:*)

      return unless symbol_node
      return unless symbol_node?(symbol_node)

      keyword.include?(symbol_node.children.first)
    end

    def value(value_node, method_node)
      return unless value_node

      if array.include?(true) && value_node.type == :array
        value_node.children.flat_map { |v| symbol_or_string(v, method_node) }
      elsif array.include?(false) && symbol_node?(value_node)
        symbol_or_string(value_node, method_node)
      end
    end

    def symbol_node?(symbol_node)
      [:sym, :str].include?(symbol_node.type)
    end

    def symbol_or_string(symbol_node, method_node)
      subnodes = symbol_node.children.first.to_s.split(/[.:]+/).map { |s| transform(s, method_node) }
      return subnodes unless definer

      subnodes.map { |s| Definition.new(s, symbol_node.loc.expression) }
    end

    def transform(string, method_node)
      string = string.to_s
      string = string.split(before, 2)[0] if before
      string = string.split(after, 2)[1] if after
      string = process_activesupport(string)
      :"#{prefix(method_node)}#{string}#{suffix}"
    end

    def prefix(method_node)
      return @prefix unless rails_delegate

      prefix = hash_value(method_node.children.last, :prefix)

      return unless prefix

      prefix = hash_value(method_node.children.last, :to) if prefix == true
      return unless prefix

      "#{prefix}_"
    end

    def hash_value(hash_node, key)
      return nil unless hash_node&.type == :hash

      pair_node = hash_node.children.find do |pair|
        key_node = pair.children.first
        next unless symbol_node?(key_node)
        next unless key_node.children.first.to_sym == key.to_sym

        true
      end

      return unless pair_node

      value_node = pair_node.children.last

      if symbol_node?(value_node)
        value_node.children.first
      else
        value_node.type == :true
      end
    end

    def test_method_name
      public_send(:another_test_method_name)

      self.foo_method_name += 1

      send("method_name_test_three")

      define_method :foo_method_name_two &:itself
    end

    def process_activesupport(string)
      return string if !activesupport || activesupport.empty?

      Forgotten.try_require('active_support/core_ext/string', "Tried transforming a rails symbol file, but the activesupport gem was not available\n`gem install activesupport`")
      Forgotten.try_require('active_support/inflections', "Tried transforming a rails symbol file, but the activesupport gem was not available\n`gem install activesupport`")
      Forgotten.try_require(File.join(Dir.pwd, 'config', 'initializers', 'inflections.rb'))

      activesupport.each do |method|
        string = string.send(method)
      end
      string
    end
  end
end

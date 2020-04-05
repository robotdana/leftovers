module Forgotten
  class ArgumentRule
    attr_accessor :group

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
      after: nil,
      before: nil,
      prefix: nil,
      suffix: nil,
      activesupport: nil,
      condition: nil,
      delete_suffix: nil,
      delete_prefix: nil,
      replace_with: nil,
      key: false,
      definer: false,
      group: nil,
      transforms: true,
      **reserved_kwargs)
      @if, @unless = extract_reserved_kwargs!(reserved_kwargs, if: nil, unless: nil)
      @if = prepare_condition(@if)
      @unless = prepare_condition(@unless)
      @keyword = prepare_keyword(keyword)
      @position = prepare_position(position, @keyword, key)
      @key = key
      @definer = definer
      @transforms = prepare_transforms({
        before: before,
        after: after,
        prefix: prefix,
        suffix: suffix,
        activesupport: Array(activesupport),
        delete_prefix: Array(delete_prefix),
        delete_suffix: Array(delete_suffix),
        replace_with: replace_with,
      }, Array(transforms))
    end

    attr_reader :position, :keyword, :transforms
    attr_reader :definer, :key

    def prepare_transforms(base, transforms)
      transforms.map do |transform|
        transform == true ? base : base.merge(transform)
      end
    end

    def prepare_condition(conditions)
      Forgotten.wrap_array(conditions).each do |cond|
        cond[:keyword] = prepare_keyword(cond[:keyword])
      end
    end

    def prepare_position(position, keyword, key)
      position = Array(position)
      return position if position && !position.empty?
      return ['**'] if (keyword && !keyword.empty?) || key
      ['*']
    end

    def prepare_keyword(keyword)
      Forgotten.wrap_array(keyword).map { |k| k.respond_to?(:to_sym) ? k.to_sym : k }
    end

    def matches(method_node)
      return [] unless all_conditions_match?(method_node)

      position.flat_map do |n|
        case n
        when '*'
          method_node.children.drop(2).flat_map { |s| value(s, method_node) }
        when '**'
          hash(kwargs(method_node), method_node)
        when 0
          method_value(method_node)
        when Integer
          value(method_node.children[n + 1], method_node)
        end
      end.compact
    end

    def all_conditions_match?(method_node)
      @if.all? { |c| condition_match?(c, method_node) } &&
        @unless.all? { |c| !condition_match?(c, method_node) }
    end

    def condition_match?(condition, method_name)
      hash_node = kwargs(method_name)

      return false unless hash_node

      condition[:keyword].all? do |kw|
        if kw.is_a?(Hash)
          kw.all? do |k, v|
            hash_value(hash_node, k.to_sym) == v || hash_value(hash_node, k.to_s) == v
          end
        else
          hash_node.children.any? do |pair|
            keyword_match?(pair.children.first, kw: Array(kw))
          end
        end
      end
    end

    def kwargs(method_node)
      hash_node = method_node.children.drop(2)[-1]
      return unless hash_node && hash_node.type == :hash

      hash_node
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

    def keyword_match?(symbol_node, kw: keyword)
      return true if kw.include?(:*)

      return unless symbol_node
      return unless symbol_node?(symbol_node)

      kw.include?(symbol_node.children.first)
    end

    def array_values(value_node, method_node)
      value_node.children.flat_map { |v| value(v, method_node) }
    end

    def value(value_node, method_node)
      return unless value_node

      case value_node.type
      when :array
        array_values(value_node, method_node)
      when :hash
        hash(value_node, method_node)
      when :str, :sym
        symbol_or_string(value_node, method_node)
      end
    end

    def symbol_node?(symbol_node)
      [:sym, :str].include?(symbol_node.type)
    end

    def symbol_or_string(symbol_node, method_node)
      subnodes = symbol_node.children.first.to_s.split(/[.:]+/).flat_map { |s| transform(s, method_node) }
      return subnodes unless definer

      Definition.wrap(subnodes, symbol_node.loc.expression)
    end

    def method_value(method_node)
      values = transform(method_node.children[1].to_s, method_node)

      return values unless definer

      Definition.wrap(values, method_node.loc.expression)
    end

    def transform(initial_string, method_node)
      transforms.map do |transform|
        string = initial_string.to_s
        string = transform[:replace_with] if transform[:replace_with]
        string = string.split(transform[:before], 2)[0] if transform[:before]
        string = string.split(transform[:after], 2)[1] if transform[:after]
        string = process_activesupport(string, transform[:activesupport])
        transform[:delete_suffix].each { |s| string = string.delete_suffix(s) }
        transform[:delete_prefix].each { |s| string = string.delete_prefix(s) }
        :"#{process_prefix(method_node, transform)}#{string}#{transform[:suffix]}"
      end
    end

    def process_prefix(method_node, transform)
      return transform[:prefix] unless transform[:prefix].is_a?(Hash)

      if transform[:prefix][:from_keyword]
        prefix = hash_value(method_node.children.last, transform[:prefix][:from_keyword]).to_s
      end

      return unless prefix

      if transform[:prefix][:joiner]
        prefix += transform[:prefix][:joiner]
      end

      prefix
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

    def process_activesupport(string, activesupport)
      return string if !activesupport || activesupport.empty?

      Forgotten.try_require('active_support/core_ext/string', "Tried transforming a rails symbol file, but the activesupport gem was not available\n`gem install activesupport`")
      Forgotten.try_require('active_support/inflections', "Tried transforming a rails symbol file, but the activesupport gem was not available\n`gem install activesupport`")
      Forgotten.try_require(File.join(Dir.pwd, 'config', 'initializers', 'inflections.rb'))

      activesupport.each do |method|
        string = string.send(method)
      end
      string
    end

    def extract_reserved_kwargs!(options, **defaults)
      invalid_options = options.keys - defaults.keys

      unless invalid_options.empty?
        raise ArgumentError, "unknown keyword#{invalid_options.length > 1 ? 's' : ''}: #{invalid_options.join(', ')}"
      end

      values = defaults.merge(options).values

      return values.first if values.length == 1

      values
    end
  end
end

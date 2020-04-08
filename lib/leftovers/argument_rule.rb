require_relative 'method_node'
require_relative 'hash_node'
module Leftovers
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
      transforms: true,
      **reserved_kwargs)
      @if, @unless = extract_reserved_kwargs!(reserved_kwargs, if: nil, unless: nil)
      @if = prepare_condition(@if)
      @unless = prepare_condition(@unless)
      @keyword = prepare_keyword(keyword)
      @position = Array(position)
      @key = key
      raise ArgumentError, "require at least one of 'position', 'keyword', 'key'" if @position.empty? && @keyword.empty? && !@key
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
      Leftovers.wrap_array(conditions).each do |cond|
        cond[:keyword] = prepare_keyword(cond[:keyword])
      end
    end

    def prepare_keyword(keyword)
      Leftovers.wrap_array(keyword).map { |k| k.respond_to?(:to_sym) ? k.to_sym : k }.to_set
    end

    def matches(method_node)
      return [] unless all_conditions_match?(method_node)

      values = position.flat_map do |n|
        case n
        when '*'
          method_node.arguments.flat_map { |s| value(s, method_node) }
        when 0
          method_value(method_node)
        when Integer
          value(method_node.arguments[n - 1], method_node)
        end
      end

      if (keyword && !keyword.empty?) || key
        values << hash_values(method_node.kwargs, method_node)
      end

      values.flatten.compact
    end

    def all_conditions_match?(method_node)
      @if.all? { |c| condition_match?(c, method_node) } &&
        @unless.all? { |c| !condition_match?(c, method_node) }
    end

    def condition_match?(condition, method_name)
      hash_node = method_name.kwargs

      return false unless hash_node

      condition[:keyword].all? do |kw|
        if kw.is_a?(Hash)
          kw.all? do |k, v|
            hash_node[k] == v
          end
        else
          hash_node.key?(kw)
        end
      end
    end

    def hash_values(hash_node, method_node)
      return unless hash_node

      out = if key == true
        hash_node.keys.map { |k| value(k, method_node) }
      else
        []
      end

      value_nodes = if keyword.include?(:'*')
        hash_node.value_nodes
      else
        hash_node.value_nodes_at(keyword)
      end

      value_nodes.each do |v|
        out << value(v, method_node)
      end

      out.flatten
    end

    def array_values(value_node, method_node)
      value_node.children.flat_map { |v| value(v, method_node) }
    end

    def value(value_node, method_node)
      return unless value_node

      case value_node
      when Symbol
        symbol_or_string(value_node, method_node)
      else
        case value_node.type
        when :array
          array_values(value_node, method_node)
        when :hash
          hash_values(HashNode.new(value_node), method_node)
        when :str, :sym
          symbol_or_string(value_node, method_node)
        end
      end
    end

    def symbol_or_string(symbol_node, method_node)
      subnodes = StringSymbolNode.try(symbol_node).parts.flat_map { |s| transform(s, method_node) }
      return subnodes unless definer

      Definition.wrap(subnodes, symbol_node.loc.expression)
    end

    def method_value(method_node)
      values = transform(method_node.name, method_node)

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
        prefix = method_node.kwargs[transform[:prefix][:from_keyword].to_sym].to_s
      end

      return unless prefix

      if transform[:prefix][:joiner]
        prefix += transform[:prefix][:joiner]
      end

      prefix
    end

    def process_activesupport(string, activesupport)
      return string if !activesupport || activesupport.empty?

      Leftovers.try_require('active_support/core_ext/string', "Tried transforming a rails symbol file, but the activesupport gem was not available\n`gem install activesupport`")
      Leftovers.try_require('active_support/inflections', "Tried transforming a rails symbol file, but the activesupport gem was not available\n`gem install activesupport`")
      Leftovers.try_require(File.join(Dir.pwd, 'config', 'initializers', 'inflections.rb'))

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

# frozen_string_literal: true

require_relative 'definition'
require_relative 'name_rule'

module Leftovers
  class ArgumentRule # rubocop:disable Metrics/ClassLength
    attr_accessor :group

    def self.wrap(rules, definer: false) # rubocop:disable Metrics/MethodLength
      case rules
      when Array
        rules.flat_map { |r| wrap(r, definer: definer) }
      when Hash
        [new(**rules, definer: definer)]
      else
        []
      end
    end

    def initialize( # rubocop:disable Metrics/ParameterLists, Metrics/MethodLength, Metrics/CyclomaticComplexity
      argument: nil,
      arguments: nil,
      key: nil,
      keys: nil,
      itself: false,
      delete_after: nil,
      delete_before: nil,
      add_prefix: nil,
      add_suffix: nil,
      activesupport: nil,
      delete_suffix: nil,
      delete_prefix: nil,
      replace_with: nil,
      definer: false,
      **reserved_kwargs
    )
      @if, @unless = extract_reserved_kwargs!(reserved_kwargs, if: nil, unless: nil)
      @if = prepare_condition(@if)
      @unless = prepare_condition(@unless)
      prepare_argument(argument, arguments)
      @key = prepare_key(key, keys)
      @definer = definer
      @itself = itself
      unless @positions || @keywords || @all_positions || @all_keywords || @key || @itself
        raise ArgumentError, "require at least one of 'argument(s)', 'key(s)', itself"
      end

      @transform = {
        delete_before: delete_before,
        delete_after: delete_after,
        add_prefix: add_prefix,
        add_suffix: add_suffix,
        activesupport: Array(activesupport),
        delete_prefix: Array(delete_prefix),
        delete_suffix: Array(delete_suffix),
        replace_with: replace_with
      }
    end

    attr_reader :definer, :transform

    def prepare_condition(conditions)
      Leftovers.wrap_array(conditions).each do |cond|
        cond[:keyword] = Leftovers.wrap_array(cond[:keyword])
          .map { |k| k.is_a?(Hash) ? k : k.to_sym }
      end
    end

    def prepare_key(key, keys)
      raise ArgumentError, 'Only use one of key/keys' if key && keys

      key || keys
    end

    def prepare_argument(argument, arguments) # rubocop:disable Metrics/PerceivedComplexity, Metrics/MethodLength, Metrics/CyclomaticComplexity, Metrics/AbcSize
      raise ArgumentError, 'Only use one of argument/arguments' if argument && arguments

      positions = Set.new
      keywords = []

      Leftovers.wrap_array(argument || arguments).each do |arg|
        case arg
        when '*'
          @all_positions = true
        when '**'
          @all_keywords = true
        when Integer
          positions << arg - 1
        when String, Symbol, Hash
          keywords << arg
        end
      end

      @positions = positions unless @all_positions || positions.empty? || @all_positions
      @keywords = NameRule.new(keywords) unless @all_keywords || keywords.empty?
    end

    def matches(method_node) # rubocop:disable Metrics/MethodLength, Metrics/PerceivedComplexity, Metrics/CyclomaticComplexity
      return [] unless all_conditions_match?(method_node)

      result = []

      if @all_positions
        result += values(method_node.positional_arguments, method_node)
      elsif @positions
        result += values(method_node.positional_arguments_at(@positions).compact, method_node)
      end

      result += hash_values(method_node.kwargs, method_node) if @keywords || @all_keywords || @key

      result << method_value(method_node) if @itself

      result
    end

    def values(value_nodes, method_node)
      value_nodes.flat_map { |value_node| value(value_node, method_node) }.compact
    end

    def all_conditions_match?(method_node)
      @if.all? { |c| condition_match?(c, method_node) } &&
        @unless.all? { |c| !condition_match?(c, method_node) }
    end

    def condition_match?(condition, method_name) # rubocop:disable Metrics/MethodLength
      hash_node = method_name.kwargs

      return false unless hash_node

      condition[:keyword].all? do |kw|
        if kw.is_a?(Hash)
          kw.all? do |k, v|
            value_node = hash_node[k]
            value_node.to_scalar_value == v if value_node&.scalar?
          end
        else
          hash_node.key?(kw)
        end
      end
    end

    def hash_values(hash_node, method_node) # rubocop:disable Metrics/MethodLength
      return [] unless hash_node

      value_nodes = []
      value_nodes += hash_node.keys if @key == '*'

      if @all_keywords
        value_nodes += hash_node.values
      elsif @keywords
        value_nodes += hash_node.values_at_match(@keywords)
      end

      values(value_nodes, method_node)
    end

    def value(value_node, method_node) # rubocop:disable Metrics/MethodLength
      return unless value_node

      case value_node.type
      when :array
        values(value_node.values, method_node)
      when :hash
        hash_values(value_node, method_node)
      when :str, :sym
        symbol_values(value_node, method_node)
      end
    end

    def symbol_values(symbol_node, method_node)
      subnodes = symbol_node.to_s.split(/[.:]+/).map { |s| do_transform(s, method_node) }
      return subnodes unless definer

      Leftovers::Definition.wrap(subnodes, symbol_node.loc.expression)
    end

    def method_value(method_node)
      value = do_transform(method_node.name, method_node)

      return value unless definer

      Leftovers::Definition.new(value, method_node.loc.expression)
    end

    def do_transform(initial_string, method_node) # rubocop:disable Metrics/MethodLength, Metrics/AbcSize
      string = initial_string.to_s
      string = transform[:replace_with] if transform[:replace_with]
      string = string.split(transform[:delete_after], 2)[0] if transform[:delete_after]
      string = string.split(transform[:delete_before], 2)[1] if transform[:delete_before]
      string = process_activesupport(string, transform[:activesupport])
      transform[:delete_suffix].each { |s| string = string.delete_suffix(s) }
      transform[:delete_prefix].each { |s| string = string.delete_prefix(s) }
      :"#{process_prefix(method_node, transform)}#{string}#{transform[:add_suffix]}"
    end

    def process_prefix(method_node, transform) # rubocop:disable Metrics/MethodLength, Metrics/AbcSize
      return transform[:add_prefix] unless transform[:add_prefix].is_a?(Hash)

      if transform[:add_prefix][:from_keyword]
        prefix = method_node.kwargs[transform[:add_prefix][:from_keyword].to_sym].to_s
      end

      return unless prefix

      prefix += transform[:add_prefix][:joiner] if transform[:add_prefix][:joiner]

      prefix
    end

    def process_activesupport(string, activesupport) # rubocop:disable Metrics/MethodLength
      return string if !activesupport || activesupport.empty?

      Leftovers.try_require(
        'active_support/core_ext/string', 'active_support/inflections',
        message: <<~MESSAGE
          Tried transforming a rails symbol file, but the activesupport gem was not available
          `gem install activesupport`
        MESSAGE
      )

      Leftovers.try_require(File.join(Dir.pwd, 'config', 'initializers', 'inflections.rb'))

      activesupport.each do |method|
        string = string.send(method)
      end
      string
    end

    def extract_reserved_kwargs!(options, **defaults) # rubocop:disable Metrics/MethodLength
      invalid = options.keys - defaults.keys

      unless invalid.empty?
        raise ArgumentError, "unknown keyword#{'s' if invalid.length > 1}: #{invalid.join(', ')}"
      end

      values = defaults.merge(options).values

      return values.first if values.length == 1

      values
    end
  end
end

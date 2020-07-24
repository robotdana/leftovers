# frozen_string_literal: true

require_relative 'definition'
require_relative 'definition_set'
require_relative 'name_rule'
require_relative 'transform_rule'
require_relative 'hash_rule'

module Leftovers
  class ArgumentRule # rubocop:disable Metrics/ClassLength
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

    ADDITIONAL_VALID_KEYS = Leftovers::TransformRule::VALID_TRANSFORMS + %i{if unless}
    def initialize( # rubocop:disable Metrics/ParameterLists, Metrics/MethodLength
      argument: nil,
      arguments: nil,
      key: nil,
      keys: nil,
      itself: false,
      linked_transforms: nil,
      transforms: nil,
      definer: false,
      **options
    )
      assert_valid_keys(options, ADDITIONAL_VALID_KEYS)
      prepare_argument(argument, arguments)
      @key = prepare_key(key, keys)
      @itself = itself

      unless @positions || @keywords || @all_positions || @all_keywords || @key || @itself
        raise Leftovers::ConfigError, "require at least one of 'argument(s)', 'key(s)', itself"
      end

      @if = prepare_condition(options.delete(:if))
      @unless = prepare_condition(options.delete(:unless))
      @transforms = prepare_transform(options, transforms, linked_transforms)
      @definer = definer
    end

    def prepare_transform(options, transforms, linked_transforms) # rubocop:disable Metrics/MethodLength, Metrics/PerceivedComplexity, Metrics/CyclomaticComplexity, Metrics/AbcSize
      if linked_transforms && transforms
        raise Leftovers::ConfigError, 'Only use one of linked_transforms/transforms'
      end
      return if !linked_transforms && !transforms && options.empty?

      if !(linked_transforms || transforms)
        @transform = TransformRule.new(options)
      else
        @linked = !!linked_transforms

        transforms = Leftovers.array_wrap(linked_transforms || transforms).map do |transform|
          transform = { transform.to_sym => true } if transform.is_a?(String)
          Leftovers::TransformRule.new(options.merge(transform))
        end

        if transforms.length <= 1
          @transform = transforms.first
        else
          @transforms = transforms
        end
      end
    end

    def prepare_condition(conditions) # rubocop:disable Metrics/MethodLength
      Leftovers.array_wrap(conditions).each do |cond|
        unless cond.is_a?(Hash) && cond.keys == [:has_argument]
          raise Leftovers::ConfigError, <<~MESSAGE
            Invalid condition #{cond.inspect}. Valid condition keys are: has_argument
          MESSAGE
        end

        cond[:has_argument] = HashRule.new(cond[:has_argument])
      end
    end

    def prepare_key(key, keys)
      raise Leftovers::ConfigError, 'Only use one of key/keys' if key && keys

      key || keys
    end

    def prepare_argument(argument, arguments) # rubocop:disable Metrics/PerceivedComplexity, Metrics/MethodLength, Metrics/CyclomaticComplexity, Metrics/AbcSize
      raise Leftovers::ConfigError, 'Only use one of argument/arguments' if argument && arguments

      positions = Set.new
      keywords = []

      Leftovers.each_or_self(argument || arguments) do |arg|
        case arg
        when '*'
          @all_positions = true
        when '**'
          @all_keywords = true
        when Integer
          positions << arg - 1
        when String, Symbol, Hash
          keywords << arg
        else
          raise Leftovers::ConfigError, <<~MESSAGE
            Invalid value for argument: #{arg.inspect}. Must by a string ('*', '**', or a keyword), or a hash with the name match rules, or an integer, or an array of these
          MESSAGE
        end
      end

      @positions = positions unless @all_positions || positions.empty? || @all_positions
      @keywords = NameRule.wrap(keywords) unless @all_keywords || keywords.empty?
    end

    def matches(method_node) # rubocop:disable Metrics/MethodLength, Metrics/PerceivedComplexity, Metrics/CyclomaticComplexity, Metrics/AbcSize
      return [].freeze unless all_conditions_match?(method_node)

      result = []

      if @all_positions
        result.leftovers_append values(method_node.positional_arguments, method_node)
      elsif @positions
        result.leftovers_append(
          values(method_node.positional_arguments_at(@positions).compact, method_node)
        )
      end

      if @keywords || @all_keywords || @key
        result.leftovers_append hash_values(method_node.kwargs, method_node)
      end
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

    def condition_match?(condition, method_node)
      method_node.positional_arguments.each.with_index(1).any? do |value, index|
        condition[:has_argument].match_pair?(index, value)
      end || method_node.kwargs&.each_pair&.any? do |key, value|
        condition[:has_argument].match_pair?(key.to_sym, value)
      end
    end

    def hash_values(hash_node, method_node) # rubocop:disable Metrics/MethodLength
      return unless hash_node

      value_nodes = []
      value_nodes.concat hash_node.keys if @key

      if @all_keywords
        value_nodes.concat(hash_node.values)
      elsif @keywords
        value_nodes.concat(hash_node.values_at_match(@keywords))
      end

      values(value_nodes, method_node)
    end

    def value(value_node, method_node) # rubocop:disable Metrics/MethodLength
      value_node = value_node.unwrap_freeze

      case value_node.type
      when :array
        values(value_node.values, method_node)
      when :hash
        hash_values(value_node, method_node)
      when :str, :sym
        symbol_values(value_node, method_node)
      end
    end

    SPLIT = /[.:]+/.freeze
    def symbol_values(symbol_node, method_node) # rubocop:disable Metrics/MethodLength
      subnodes = Array(transform(symbol_node.to_s, method_node))
        .flat_map { |s| s.to_s.split(SPLIT).map(&:to_sym) }

      return subnodes unless @definer

      location = symbol_node.loc.expression
      if @linked
        Leftovers::DefinitionSet.new(subnodes, location: location, method_node: method_node)
      else
        subnodes.map do |subnode|
          Leftovers::Definition.new(subnode, location: location, method_node: method_node)
        end
      end
    end

    def method_value(method_node)
      value = transform(method_node.to_s, method_node)

      return value unless @definer

      Leftovers::Definition.new(value, method_node: method_node)
    end

    def transform(string, method_node)
      return string unless @transform || @transforms
      return @transform.transform(string, method_node) if @transform

      @transforms.map do |transform|
        transform.transform(string, method_node)
      end
    end

    def assert_valid_keys(options, keys) # rubocop:disable Metrics/MethodLength
      invalid = options.keys - keys

      return if invalid.empty?

      raise(
        Leftovers::ConfigError,
        "unknown keyword#{'s' if invalid.length > 1}: #{invalid.join(', ')}"
      )
    end
  end
end

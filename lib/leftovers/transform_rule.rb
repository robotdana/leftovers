# frozen_string_literal: true

module Leftovers
  class TransformRule # rubocop:disable Metrics/ClassLength
    RUBY_STRING_METHODS = %i{
      downcase
      upcase
      capitalize
      swapcase
    }.freeze

    ACTIVESUPPORT_STRING_METHODS = %i{
      pluralize
      singularize
      camelize
      camelcase
      underscore
      titleize
      titlecase
      demodulize
      deconstantize
      parameterize
    }.freeze

    CUSTOM_TRANSFORMS = %i{
      original
      delete_before
      delete_after
      add_prefix
      add_suffix
      delete_prefix
      delete_suffix
      replace_with
    }.freeze

    VALID_TRANSFORMS = RUBY_STRING_METHODS + ACTIVESUPPORT_STRING_METHODS + CUSTOM_TRANSFORMS
    # more possible transformations
    # gsub sub tr tr_s
    def initialize(transforms)
      @transforms = prepare_transforms(transforms)

      freeze
    end

    def transform(original_string, method_node)
      string = original_string
      @transforms.each { |proc| string = proc.call(string, method_node) }

      string.to_sym
    end

    private

    def prepare_transforms(transforms) # rubocop:disable Metrics/MethodLength
      transforms.map do |key, value|
        unless VALID_TRANSFORMS.include?(key)
          raise ArgumentError, <<~MESSAGE
            invalid transform key: (#{key}: #{value}).
            Valid transform keys are #{ALL_VALID_TRANSFORMS}"
          MESSAGE
        end

        key, value = prepare_hash_value(key, value) if value.is_a?(Hash)

        instance_variable_set(:"@#{key}", value.freeze)
        method(key)
      end
    end

    HASH_VALUE_TRANSFORMS = %i{add_prefix add_suffix}.freeze
    HASH_VALUE_KEYS = %i{from_argument joiner}.freeze
    def prepare_hash_value(method, hash) # rubocop:disable Metrics/MethodLength
      raise ArgumentError, <<~MESSAGE unless HASH_VALUE_TRANSFORMS.include?(method)
        invalid transform value (#{key}: #{value}).
        Hash values are only valid for #{HASH_VALUE_TRANSFORMS}
      MESSAGE

      hash = hash.map do |k, v|
        raise ArgumentError, <<~MESSAGE unless HASH_VALUE_KEYS.include?(k)
          invalid transform value argument (#{method}: { #{k}: #{v} }).
          Hash values are only valid for #{HASH_VALUE_TRANSFORMS}
        MESSAGE

        [k, v.to_sym]
      end.to_h

      ["#{method}_dynamic", hash]
    end

    RUBY_STRING_METHODS.each do |method|
      class_eval <<~RUBY, __FILE__, __LINE__ + 1
        def #{method}(string, _method_node)
          string.#{method}
        end
      RUBY
    end

    # leftovers:call activesupport_available?
    ACTIVESUPPORT_STRING_METHODS.each do |method|
      class_eval <<-RUBY, __FILE__, __LINE__ + 1
        def #{method}(string, _method_node)
          return string unless activesupport_available?(:#{method})

          string.#{method}
        end
      RUBY
    end

    def original(string, _method_node)
      string
    end

    def delete_prefix(string, _method_node)
      string.delete_prefix(@delete_prefix)
    end

    def delete_suffix(string, _method_node)
      string.delete_suffix(@delete_suffix)
    end

    def delete_before(string, _method_node)
      string.split(@delete_before, 2)[1] || string
    end

    def delete_after(string, _method_node)
      string.split(@delete_after, 2).first
    end

    def replace_with(_string, _method_node)
      @replace_with
    end

    def add_prefix(string, _method_node)
      "#{@add_prefix}#{string}"
    end

    def add_suffix(string, _method_node)
      "#{string}#{@add_suffix}"
    end

    def add_prefix_dynamic(string, method_node)
      "#{dynamic_value(@add_prefix_dynamic, method_node)}#{@add_prefix_dynamic[:joiner]}#{string}"
    end

    def add_suffix_dynamic(string, method_node)
      "#{string}#{@add_suffix_dynamic[:joiner]}#{dynamic_value(@add_suffix_dynamic, method_node)}"
    end

    def dynamic_value(value, method_node)
      method_node.kwargs[value[:from_argument]].to_s if value[:from_argument]
    end

    def activesupport_available?(method) # rubocop:disable Metrics/MethodLength
      Leftovers.try_require(
        'active_support/core_ext/string', 'active_support/inflections',
        message: <<~MESSAGE
          Tried transforming a string using an activesupport method (#{method}), but the activesupport gem was not available
          `gem install activesupport`
        MESSAGE
      )

      Leftovers.try_require(::File.join(Leftovers.pwd, 'config', 'initializers', 'inflections.rb'))

      defined?(ActiveSupport)
    end
  end
end

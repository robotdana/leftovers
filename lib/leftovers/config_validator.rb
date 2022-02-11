# frozen-string-literal: true

require 'set'
require 'json_schemer'

module Leftovers
  module ConfigValidator
    autoload(:ErrorProcessor, "#{__dir__}/config_validator/error_processor")
    autoload(:SCHEMA_HASH, "#{__dir__}/config_validator/schema_hash")

    def self.default_schema
      @default_schema ||= ::JSONSchemer.schema(::Leftovers::ConfigValidator::SCHEMA_HASH)
    end

    def self.validate(obj, validator = default_schema)
      validator.validate(obj)
    end

    def self.validate_and_process!(yaml, path)
      errors = validate(yaml)
      print_validation_errors_and_exit(errors, path) unless errors.first.nil?
      post_process!(yaml)
    end

    def self.print_validation_errors_and_exit(errors, path)
      ::Leftovers::ConfigValidator::ErrorProcessor.process(errors).each do |message|
        warn "\e[31mConfig SchemaError: (#{path}): #{message}\e[0m"
      end

      ::Leftovers.exit 1
    end

    def self.post_process!(obj)
      case obj
      when Hash
        obj.keys.each do |key| # rubocop:disable Style/HashEachMethods # each_key never finishes.
          obj[symbolize_name(key)] = post_process!(obj.delete(key))
        end
      when Array
        obj.map! { |ea| post_process!(ea) }
      end
      obj
    end

    def self.symbolize_name(name) # rubocop:disable Metrics/MethodLength, Metrics/CyclomaticComplexity
      case name
      when 'matches' then :match
      when 'defines' then :define
      when 'calls' then :call
      when 'name' then :names
      when 'keyword' then :keywords
      when 'argument' then :arguments
      when 'has_argument' then :has_arguments
      when 'path' then :paths
      when 'unless' then :unless_arg
      when 'require' then :requires
      else name.to_sym
      end
    end
  end
end

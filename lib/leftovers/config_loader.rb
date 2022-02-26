# frozen-string-literal: true

require 'yaml'

module Leftovers
  class ConfigLoader
    autoload(:ArgumentPositionSchema, "#{__dir__}/config_loader/argument_position_schema")
    autoload(:ArgumentlessTransformSchema, "#{__dir__}/config_loader/argumentless_transform_schema")
    autoload(:Attribute, "#{__dir__}/config_loader/attribute")
    autoload(:BuiltInPrecompilerSchema, "#{__dir__}/config_loader/built_in_precompiler_schema")
    autoload(:DocumentSchema, "#{__dir__}/config_loader/document_schema")
    autoload(:DynamicSchema, "#{__dir__}/config_loader/dynamic_schema")
    autoload(:InheritSchemaAttributes, "#{__dir__}/config_loader/inherit_schema_attributes")
    autoload(:HasArgumentSchema, "#{__dir__}/config_loader/has_argument_schema")
    autoload(:HasValueSchema, "#{__dir__}/config_loader/has_value_schema")
    autoload(:KeepTestOnlySchema, "#{__dir__}/config_loader/keep_test_only_schema")
    autoload(:Node, "#{__dir__}/config_loader/node")
    autoload(:ObjectSchema, "#{__dir__}/config_loader/object_schema")
    autoload(:PrecompileSchema, "#{__dir__}/config_loader/precompile_schema")
    autoload(:PrecompilerSchema, "#{__dir__}/config_loader/precompiler_schema")
    autoload(:PrivacyProcessorSchema, "#{__dir__}/config_loader/privacy_processor_schema")
    autoload(:PrivacySchema, "#{__dir__}/config_loader/privacy_schema")
    autoload(:RequireSchema, "#{__dir__}/config_loader/require_schema")
    autoload(:RulePatternSchema, "#{__dir__}/config_loader/rule_pattern_schema")
    autoload(:ScalarArgumentSchema, "#{__dir__}/config_loader/scalar_argument_schema")
    autoload(:ScalarValueSchema, "#{__dir__}/config_loader/scalar_value_schema")
    autoload(:Schema, "#{__dir__}/config_loader/schema")
    autoload(:Suggester, "#{__dir__}/config_loader/suggester")
    autoload(:StringEnumSchema, "#{__dir__}/config_loader/string_enum_schema")
    autoload(:StringPatternSchema, "#{__dir__}/config_loader/string_pattern_schema")
    autoload(:StringSchema, "#{__dir__}/config_loader/string_schema")
    autoload(:StringValueProcessorSchema, "#{__dir__}/config_loader/string_value_processor_schema")
    autoload(:TransformSchema, "#{__dir__}/config_loader/transform_schema")
    autoload(:TrueSchema, "#{__dir__}/config_loader/true_schema")
    autoload(:ValueMatcherSchema, "#{__dir__}/config_loader/value_matcher_schema")
    autoload(:ValueOrArraySchema, "#{__dir__}/config_loader/value_or_array_schema")
    autoload(:ValueProcessorSchema, "#{__dir__}/config_loader/value_processor_schema")
    autoload(:ValueTypeSchema, "#{__dir__}/config_loader/value_type_schema")

    def self.load(name, path: nil, content: nil)
      new(name, path: path, content: content).load
    end

    attr_reader :name

    def initialize(name, path: nil, content: nil)
      @name = name
      @path = path
      @content = content
    end

    def load
      document = ::Leftovers::ConfigLoader::Node.new(parse, file)
      DocumentSchema.validate(document)

      all_errors = document.all_errors
      return DocumentSchema.to_ruby(document) if all_errors.empty?

      Leftovers.error(all_errors.join("\n"))
    end

    private

    def path
      @path ||= ::File.expand_path("../config/#{name}.yml", __dir__)
    end

    def file
      @file ||= ::Leftovers::File.new(path)
    end

    def content
      @content ||= file.exist? ? file.read : ''
    end

    def parse
      parsed = Psych.parse(content)
      parsed ||= Psych.parse('{}')
      parsed.children.first
    rescue ::Psych::SyntaxError => e
      message = [e.problem, e.context].compact.join(' ')
      Leftovers.error "Config SyntaxError: #{file.relative_path}:#{e.line}:#{e.column} #{message}"
    end
  end
end

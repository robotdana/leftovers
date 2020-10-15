# frozen-string-literal: true

require 'json_schemer'

module Leftovers
  module ConfigValidator # rubocop:disable Metrics/ModuleLength
    AVAILABLE_GEMS = %w{
      attr_encrypted audited builder capistrano datagrid flipper graphql guard haml jbuilder
      okcomputer parser pry rack rails rake redcarpet rollbar rspec ruby selenium-webdriver sidekiq
      simplecov will_paginate
    }.freeze

    SCHEMA_HASH = {
      '$schema' => 'http://json-schema.org/draft-06/schema#',
      'type' => 'object',
      'definitions' => {
        'true' => { 'type' => 'boolean', 'enum' => [true] },
        'string' => {
          'type' => 'string',
          'minLength' => 1,
          'pattern' => '\S'
        },
        'stringPattern' => {
          'type' => 'object',
          'properties' => {
            'match' => { '$ref' => '#/definitions/string' },
            'matches' => { '$ref' => '#/definitions/string' },
            'has_prefix' => { '$ref' => '#/definitions/string' },
            'has_suffix' => { '$ref' => '#/definitions/string' }
          },
          'minProperties' => 0,
          'additionalProperties' => true,
          'allOf' => [
            # synonyms
            { 'not' => { 'required' => %w{match matches} } },
            # incompatible groups
            { 'not' => { 'required' => %w{match has_prefix} } },
            { 'not' => { 'required' => %w{match has_suffix} } },
            { 'not' => { 'required' => %w{matches has_prefix} } },
            { 'not' => { 'required' => %w{matches has_suffix} } }
          ]
        },
        'path' => { '$ref' => '#/definitions/string' },
        'pathList' => {
          'anyOf' => [
            {
              'type' => 'array',
              'items' => { '$ref' => '#/definitions/path' },
              'minItems' => 1,
              'uniqueItems' => true
            },
            { '$ref' => '#/definitions/path' }
          ]
        },
        'name' => {
          'anyOf' => [
            { '$ref' => '#/definitions/string' },
            { 'allOf' => [
              { '$ref' => '#/definitions/stringPattern' },
              {
                'properties' => {
                  'match' => true, 'matches' => true,
                  'has_prefix' => true, 'has_suffix' => true,
                  'unless' => { '$ref' => '#/definitions/nameList' },
                  'not' => { '$ref' => '#/definitions/nameList' }
                },
                'minProperties' => 1,
                'additionalProperties' => false
              },
              # synonyms
              { 'not' => { 'required' => %w{not unless} } }
            ] }
          ]
        },
        'nameList' => {
          'anyOf' => [
            {
              'type' => 'array',
              'items' => { '$ref' => '#/definitions/name' },
              'minItems' => 1,
              'uniqueItems' => true
            },
            { '$ref' => '#/definitions/name' }
          ]
        },
        'argumentPosition' => {
          'anyOf' => [
            { '$ref' => '#/definitions/string' },
            { 'type' => 'integer', 'minimum' => 1 }
          ]
        },
        'argumentPositionList' => {
          'anyOf' => [
            { '$ref' => '#/definitions/argumentPosition' },
            {
              'type' => 'array',
              'items' => { '$ref' => '#/definitions/argumentPosition' },
              'minItems' => 1,
              'uniqueItems' => true
            }
          ]
        },
        'valueType' => {
          'type' => 'string',
          'enum' => %w{String Symbol Integer Float Method Constant}
        },
        'valueTypeList' => {
          'anyOf' => [
            { '$ref' => '#/definitions/valueType' },
            {
              'type' => 'array',
              'items' => { '$ref' => '#/definitions/valueType' },
              'minItems' => 1,
              'uniqueItems' => true
            }
          ]
        },
        'value' => {
          'allOf' => [
            { 'not' => { 'type' => 'array' } },
            { 'anyOf' => [
              { 'not' => { 'type' => 'object' } },
              {
                'type' => 'object',
                'properties' => {
                  'type' => { '$ref' => '#/definitions/valueTypeList' }
                },
                'additionalProperties' => false,
                'required' => ['type']
              }
            ] }
          ]
        },
        'valueList' => {
          'anyOf' => [
            { '$ref' => '#/definitions/value' },
            {
              'type' => 'array',
              'items' => { '$ref' => '#/definitions/value' },
              'minItems' => 1,
              'uniqueItems' => true
            }
          ]
        },
        'hasArgument' => {
          'anyOf' => [
            { '$ref' => '#/definitions/string' },
            { 'type' => 'integer', 'minimum' => 1 },
            {
              'type' => 'object',
              'properties' => {
                'at' => { '$ref' => '#/definitions/argumentPositionList' },
                'value' => { '$ref' => '#/definitions/valueList' },
                'unless' => { '$ref' => '#/definitions/hasArgumentList' }
              }
            }
          ]
        },
        'hasArgumentList' => {
          'anyOf' => [
            { '$ref' => '#/definitions/hasArgument' },
            {
              'type' => 'array',
              'items' => { '$ref' => '#/definitions/hasArgument' },
              'minItems' => 1,
              'uniqueItems' => true
            }
          ]
        },
        'ruleMatcherList' => {
          'anyOf' => [
            { 'allOf' => [
              { '$ref' => '#/definitions/ruleMatcher' },
              {
                'properties' => {
                  # unfortunately this repetition is necessary to use additionalProperties: false
                  'name' => true, 'names' => true,
                  'path' => true, 'paths' => true,
                  'has_argument' => true, 'has_arguments' => true,
                  'unless' => true, 'not' => true
                },
                'additionalProperties' => false
              }
            ] },
            {
              'type' => 'array',
              'items' => { '$ref' => '#/definitions/ruleMatcher' },
              'minItems' => 1,
              'uniqueItems' => true
            }
          ]
        },
        'ruleMatcher' => {
          'type' => 'object',
          'properties' => {
            'name' => { '$ref' => '#/definitions/nameList' },
            'names' => { '$ref' => '#/definitions/nameList' },
            'path' => { '$ref' => '#/definitions/pathList' },
            'paths' => { '$ref' => '#/definitions/pathList' },
            'has_argument' => { '$ref' => '#/definitions/hasArgumentList' },
            'has_arguments' => { '$ref' => '#/definitions/hasArgumentList' },
            'unless' => { '$ref' => '#/definitions/ruleMatcherList' },
            'not' => { '$ref' => '#/definitions/ruleMatcherList' }
          },
          'minProperties' => 1,
          'additionalProperties' => true,
          'allOf' => [
            # synonyms
            { 'not' => { 'required' => %w{name names} } },
            { 'not' => { 'required' => %w{path paths} } },
            { 'not' => { 'required' => %w{has_argument has_arguments} } },
            { 'not' => { 'required' => %w{unless not} } },
            # At least one of
            { 'anyOf' => [
              { 'required' => ['name'] }, { 'required' => ['names'] },
              { 'required' => ['path'] }, { 'required' => ['paths'] },
              { 'required' => ['has_argument'] }, { 'required' => ['has_arguments'] },
              { 'required' => ['unless'] }, { 'required' => ['not'] }
            ] }
          ]
        },
        'dynamicString' => {
          'anyOf' => [
            { '$ref' => '#/definitions/string' },
            {
              'type' => 'object',
              'properties' => {
                'from_argument' => { '$ref' => '#/definitions/argumentPosition' },
                'joiner' => { '$ref' => '#/definitions/string' }
              },
              'additionalProperties' => false
            }
          ]
        },
        'transformProperties' => {
          'type' => 'object',
          'properties' => {
            'original' => { '$ref' => '#/definitions/true' },
            'pluralize' => { '$ref' => '#/definitions/true' },
            'singularize' => { '$ref' => '#/definitions/true' },
            'camelize' => { '$ref' => '#/definitions/true' },
            'camelcase' => { '$ref' => '#/definitions/true' },
            'underscore' => { '$ref' => '#/definitions/true' },
            'titleize' => { '$ref' => '#/definitions/true' },
            'titlecase' => { '$ref' => '#/definitions/true' },
            'demodulize' => { '$ref' => '#/definitions/true' },
            'deconstantize' => { '$ref' => '#/definitions/true' },
            'parameterize' => { '$ref' => '#/definitions/true' },
            'downcase' => { '$ref' => '#/definitions/true' },
            'upcase' => { '$ref' => '#/definitions/true' },
            'capitalize' => { '$ref' => '#/definitions/true' },
            'swapcase' => { '$ref' => '#/definitions/true' },

            'add_prefix' => { '$ref' => '#/definitions/dynamicString' },
            'add_suffix' => { '$ref' => '#/definitions/dynamicString' },

            'delete_prefix' => { '$ref' => '#/definitions/string' },
            'delete_suffix' => { '$ref' => '#/definitions/string' },
            'delete_before' => { '$ref' => '#/definitions/string' },
            'delete_after' => { '$ref' => '#/definitions/string' },
            'replace_with' => { '$ref' => '#/definitions/string' }
          }
        },
        'transform' => {
          'anyOf' => [
            {
              'type' => 'string',
              'enum' => %w{
                original
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
                downcase
                upcase
                capitalize
                swapcase
              }
            },
            { 'allOf' => [
              { '$ref' => '#/definitions/transformProperties' },
              {
                'properties' => {
                  'original' => true,
                  'pluralize' => true,
                  'singularize' => true,
                  'camelize' => true,
                  'camelcase' => true,
                  'underscore' => true,
                  'titleize' => true,
                  'titlecase' => true,
                  'demodulize' => true,
                  'deconstantize' => true,
                  'parameterize' => true,
                  'downcase' => true,
                  'upcase' => true,
                  'capitalize' => true,
                  'swapcase' => true,
                  'add_prefix' => true,
                  'add_suffix' => true,
                  'delete_prefix' => true,
                  'delete_suffix' => true,
                  'delete_before' => true,
                  'delete_after' => true,
                  'replace_with' => true
                },
                'additionalProperties' => false
              }
            ] }
          ]
        },
        'transformList' => {
          'anyOf' => [
            { '$ref' => '#/definitions/transform' },
            {
              'type' => 'array',
              'items' => { '$ref' => '#/definitions/transform' },
              'minItems' => 1,
              'uniqueItems' => true
            }
          ]
        },
        'action' => {
          'allOf' => [
            { '$ref' => '#/definitions/transformProperties' },
            {
              'type' => 'object',
              'properties' => {
                'original' => true,
                'pluralize' => true,
                'singularize' => true,
                'camelize' => true,
                'camelcase' => true,
                'underscore' => true,
                'titleize' => true,
                'titlecase' => true,
                'demodulize' => true,
                'deconstantize' => true,
                'parameterize' => true,
                'downcase' => true,
                'upcase' => true,
                'capitalize' => true,
                'swapcase' => true,
                'add_prefix' => true,
                'add_suffix' => true,
                'delete_prefix' => true,
                'delete_suffix' => true,
                'delete_before' => true,
                'delete_after' => true,
                'replace_with' => true,
                'argument' => { '$ref' => '#/definitions/argumentPositionList' },
                'arguments' => { '$ref' => '#/definitions/argumentPositionList' },
                'itself' => { '$ref' => '#/definitions/true' },
                'keys' => true,
                'transforms' => { '$ref' => '#/definitions/transformList' },
                'linked_transforms' => { '$ref' => '#/definitions/transformList' }
              },
              'additionalProperties' => false,
              'allOf' => [
                { 'not' => { 'required' => %w{argument arguments} } }
              ]
            }
          ]
        },
        'actionList' => {
          'anyOf' => [
            { '$ref' => '#/definitions/action' },
            {
              'type' => 'array',
              'items' => { '$ref' => '#/definitions/action' },
              'minItems' => 1,
              'uniqueItems' => true
            }
          ]
        },
        'ruleAction' => {
          'type' => 'object',
          'properties' => {
            'call' => { '$ref' => '#/definitions/actionList' },
            'calls' => { '$ref' => '#/definitions/actionList' },
            'define' => { '$ref' => '#/definitions/actionList' },
            'defines' => { '$ref' => '#/definitions/actionList' },
            'skip' => { '$ref' => '#/definitions/true' }
          },
          'additionalProperties' => true,
          'minProperties' => 1,
          'allOf' => [
            # synonyms
            { 'not' => { 'required' => %w{call calls} } },
            { 'not' => { 'required' => %w{define defines} } },
            { 'not' => { 'required' => %w{skip skips} } },
            # incompatible groups
            { 'not' => { 'required' => %w{skip call} } },
            { 'not' => { 'required' => %w{skip calls} } },
            { 'not' => { 'required' => %w{skip defines} } },
            { 'not' => { 'required' => %w{skip define} } },
            # At least one of
            { 'anyOf' => [
              { 'required' => ['call'] }, { 'required' => ['calls'] },
              { 'required' => ['define'] }, { 'required' => ['defines'] },
              { 'required' => ['skip'] }
            ] }
          ]
        },
        'rule' => {
          'allOf' => [
            { '$ref' => '#/definitions/ruleMatcher' },
            { '$ref' => '#/definitions/ruleAction' },
            {
              'properties' => {
                # unfortunately this repetition is necessary to use additionalProperties: false
                'name' => true, 'names' => true,
                'path' => true, 'paths' => true,
                'has_argument' => true, 'has_arguments' => true,
                'unless' => true, 'not' => true,

                'call' => true, 'calls' => true,
                'define' => true, 'defines' => true,
                'skip' => true
              },
              'additionalProperties' => false,
              'minProperties' => 2
            }
          ]
        },
        'ruleList' => {
          'anyOf' => [
            {
              'type' => 'array',
              'items' => { '$ref' => '#/definitions/rule' },
              'minItems' => 1,
              'uniqueItems' => true
            },
            { '$ref' => '#/definitions/rule' }
          ]
        }
      },
      'properties' => {
        'include_paths' => { '$ref' => '#/definitions/pathList' },
        'exclude_paths' => { '$ref' => '#/definitions/pathList' },
        'test_paths' => { '$ref' => '#/definitions/pathList' },
        'gems' => {
          'type' => 'string',
          'enum' => AVAILABLE_GEMS
        },
        'rules' => { '$ref' => '#/definitions/ruleList' }
      }
    }.freeze
    SCHEMA = JSONSchemer.schema(SCHEMA_HASH)

    def self.validate(obj, validator = SCHEMA)
      validator.validate(obj).map { |x| JSONSchemer::Errors.pretty(x) }
    end
  end
end

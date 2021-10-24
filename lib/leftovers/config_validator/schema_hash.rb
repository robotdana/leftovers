# frozen-string-literal: true

module Leftovers
  module ConfigValidator # rubocop:disable Metrics/ModuleLength
    SCHEMA_HASH = {
      '$schema' => 'http://json-schema.org/draft-06/schema#',
      'type' => 'object',
      'definitions' => {
        'true' => { 'enum' => [true, 'true'] },
        'string' => {
          'type' => 'string',
          'minLength' => 1
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
        'stringList' => {
          'anyOf' => [
            {
              'type' => 'array',
              'items' => { '$ref' => '#/definitions/string' },
              'minItems' => 1,
              'uniqueItems' => true
            },
            { '$ref' => '#/definitions/string' }
          ]
        },
        'name' => {
          'anyOf' => [
            { '$ref' => '#/definitions/string' },
            { 'allOf' => [
              { '$ref' => '#/definitions/stringPattern' },
              {
                'type' => 'object',
                'properties' => {
                  'match' => true, 'matches' => true,
                  'has_prefix' => true, 'has_suffix' => true,
                  'unless' => { '$ref' => '#/definitions/nameList' }
                },
                'minProperties' => 1,
                'additionalProperties' => false
              }
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
            { 'type' => 'integer', 'minimum' => 0 },
            { '$ref' => '#/definitions/name' }
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
          'enum' => %w{String Symbol Integer Float Array Hash Proc}
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
        'hasValue' => {
          'anyOf' => [
            { 'type' => 'string' },
            { 'type' => 'integer' },
            { 'type' => 'number' },
            { 'type' => 'boolean' },
            { 'type' => 'null' },
            { 'allOf' => [
              { '$ref' => '#/definitions/stringPattern' },
              {
                'type' => 'object',
                'properties' => {
                  'match' => true, 'matches' => true,
                  'has_prefix' => true, 'has_suffix' => true,
                  'at' => { '$ref' => '#/definitions/argumentPositionList' },
                  'has_value' => { '$ref' => '#/definitions/hasValueList' },
                  'type' => { '$ref' => '#/definitions/valueTypeList' },
                  'unless' => { '$ref' => '#/definitions/hasValueList' }
                },
                'minProperties' => 1,
                'additionalProperties' => false,
                'allOf' => [
                  # incompatible groups
                  { 'not' => { 'required' => %w{match at} } },
                  { 'not' => { 'required' => %w{match has_value} } },
                  { 'not' => { 'required' => %w{match type} } },
                  { 'not' => { 'required' => %w{matches at} } },
                  { 'not' => { 'required' => %w{matches has_value} } },
                  { 'not' => { 'required' => %w{matches type} } },
                  { 'not' => { 'required' => %w{has_prefix at} } },
                  { 'not' => { 'required' => %w{has_prefix has_value} } },
                  { 'not' => { 'required' => %w{has_prefix type} } },
                  { 'not' => { 'required' => %w{has_suffix at} } },
                  { 'not' => { 'required' => %w{has_suffix has_value} } },
                  { 'not' => { 'required' => %w{has_suffix type} } },
                  { 'not' => { 'required' => %w{at type} } },
                  { 'not' => { 'required' => %w{has_value type} } }
                ]
              }
            ] }
          ]
        },
        'hasValueList' => {
          'anyOf' => [
            { '$ref' => '#/definitions/hasValue' },
            {
              'type' => 'array',
              'items' => { '$ref' => '#/definitions/hasValue' },
              'minItems' => 1,
              'uniqueItems' => true
            }
          ]
        },
        'hasArgument' => {
          'anyOf' => [
            { '$ref' => '#/definitions/string' },
            { 'type' => 'integer', 'minimum' => 0 },
            {
              'type' => 'object',
              'properties' => {
                'at' => { '$ref' => '#/definitions/argumentPositionList' },
                'has_value' => { '$ref' => '#/definitions/hasValueList' },
                'unless' => { '$ref' => '#/definitions/hasArgumentList' }
              },
              'minProperties' => 1,
              'additionalProperties' => false,
              'allOf' => [
                # synonyms
                { 'not' => { 'required' => %w{has_argument has_arguments} } }
              ]
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
        'rulePattern' => {
          'type' => 'object',
          'properties' => {
            'name' => { '$ref' => '#/definitions/nameList' },
            'names' => { '$ref' => '#/definitions/nameList' },
            'path' => { '$ref' => '#/definitions/stringList' },
            'paths' => { '$ref' => '#/definitions/stringList' },
            'has_argument' => { '$ref' => '#/definitions/hasArgumentList' },
            'has_arguments' => { '$ref' => '#/definitions/hasArgumentList' }
          },
          'minProperties' => 1,
          'allOf' => [
            # synonyms
            { 'not' => { 'required' => %w{name names} } },
            { 'not' => { 'required' => %w{path paths} } },
            { 'not' => { 'required' => %w{has_argument has_arguments} } }
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

            'add_prefix' => { '$ref' => '#/definitions/actionList' },
            'add_suffix' => { '$ref' => '#/definitions/actionList' },

            'split' => { '$ref' => '#/definitions/string' },
            'delete_prefix' => { '$ref' => '#/definitions/string' },
            'delete_suffix' => { '$ref' => '#/definitions/string' },
            'delete_before' => { '$ref' => '#/definitions/string' },
            'delete_after' => { '$ref' => '#/definitions/string' }
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
                  'split' => true,
                  'delete_prefix' => true,
                  'delete_suffix' => true,
                  'delete_before' => true,
                  'delete_after' => true
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
        'keyword' => {
          'anyOf' => [
            { '$ref' => '#/definitions/name' }
          ]
        },
        'keywordList' => {
          'anyOf' => [
            { '$ref' => '#/definitions/keyword' },
            {
              'type' => 'array',
              'items' => { '$ref' => '#/definitions/keyword' },
              'minItems' => 1,
              'uniqueItems' => true
            }
          ]
        },
        'action' => {
          'anyOf' => [
            { '$ref' => '#/definitions/string' },
            { 'type' => 'integer', 'minimum' => 0 },
            { 'allOf' => [
              { '$ref' => '#/definitions/transformProperties' },
              {
                'type' => 'object',
                'properties' => {
                  'argument' => { '$ref' => '#/definitions/argumentPositionList' },
                  'arguments' => { '$ref' => '#/definitions/argumentPositionList' },
                  'keyword' => { '$ref' => '#/definitions/keywordList' },
                  'keywords' => { '$ref' => '#/definitions/keywordList' },
                  'itself' => { '$ref' => '#/definitions/true' },
                  'value' => { '$ref' => '#/definitions/string' },
                  'nested' => { '$ref' => '#/definitions/actionList' },
                  'recursive' => { '$ref' => '#/definitions/true' },
                  'transforms' => { '$ref' => '#/definitions/transformList' },
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
                  'split' => true,
                  'delete_prefix' => true,
                  'delete_suffix' => true,
                  'delete_before' => true,
                  'delete_after' => true
                },
                'additionalProperties' => false,
                'allOf' => [
                  # synonyms
                  { 'not' => { 'required' => %w{keyword keywords} } },
                  { 'not' => { 'required' => %w{argument arguments} } },
                  # any of
                  { 'anyOf' => [
                    { 'required' => ['argument'] },
                    { 'required' => ['arguments'] },
                    { 'required' => ['keyword'] },
                    { 'required' => ['keywords'] },
                    { 'required' => ['itself'] },
                    { 'required' => ['value'] }
                  ] }
                ]
              }
            ] }
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
        'dynamicAction' => {
          'type' => 'object',
          'properties' => {
            'call' => { '$ref' => '#/definitions/actionList' },
            'calls' => { '$ref' => '#/definitions/actionList' },
            'define' => { '$ref' => '#/definitions/actionList' },
            'defines' => { '$ref' => '#/definitions/actionList' }
          },
          'additionalProperties' => true,
          'minProperties' => 1,
          'allOf' => [
            # synonyms
            { 'not' => { 'required' => %w{call calls} } },
            { 'not' => { 'required' => %w{define defines} } },
            # At least one of
            { 'anyOf' => [
              { 'required' => ['call'] }, { 'required' => ['calls'] },
              { 'required' => ['define'] }, { 'required' => ['defines'] }
            ] }
          ]
        },
        'ruleMatcherList' => {
          'anyOf' => [
            {
              'type' => 'array',
              'items' => { '$ref' => '#/definitions/ruleMatcher' },
              'minItems' => 1,
              'uniqueItems' => true
            },
            { '$ref' => '#/definitions/ruleMatcher' }
          ]
        },
        'ruleMatcher' => {
          'allOf' => [
            { '$ref' => '#/definitions/rulePattern' },
            { 'anyOf' => [
              { 'required' => ['name'] }, { 'required' => ['names'] },
              { 'required' => ['path'] }, { 'required' => ['paths'] },
              { 'required' => ['has_argument'] }, { 'required' => ['has_arguments'] },
              { 'required' => ['unless'] }
            ] },
            {
              'type' => 'object',
              'properties' => {
                # unfortunately this repetition is necessary to use additionalProperties: false
                'name' => true, 'names' => true,
                'path' => true, 'paths' => true,
                'has_argument' => true, 'has_arguments' => true,
                'unless' => { '$ref' => '#/definitions/ruleMatcherList' }

              },
              'additionalProperties' => false,
              'minProperties' => 1
            }
          ]
        },
        'dynamic' => {
          'allOf' => [
            { '$ref' => '#/definitions/rulePattern' },
            { '$ref' => '#/definitions/dynamicAction' },
            { 'anyOf' => [
              { 'required' => ['name'] }, { 'required' => ['names'] },
              { 'required' => ['path'] }, { 'required' => ['paths'] },
              { 'required' => ['has_argument'] }, { 'required' => ['has_arguments'] },
              { 'required' => ['unless'] }
            ] },
            {
              'type' => 'object',
              'properties' => {
                # unfortunately this repetition is necessary to use additionalProperties: false
                'name' => true, 'names' => true,
                'path' => true, 'paths' => true,
                'has_argument' => true, 'has_arguments' => true,
                'unless' => { '$ref' => '#/definitions/ruleMatcherList' },

                'call' => true, 'calls' => true,
                'define' => true, 'defines' => true
              },
              'additionalProperties' => false,
              'minProperties' => 1
            }
          ]
        },
        'dynamicList' => {
          'anyOf' => [
            {
              'type' => 'array',
              'items' => { '$ref' => '#/definitions/dynamic' },
              'minItems' => 1,
              'uniqueItems' => true
            },
            { '$ref' => '#/definitions/dynamic' }
          ]
        },
        'keepTestOnly' => {
          'anyOf' => [
            { '$ref' => '#/definitions/string' },
            {
              'allOf' => [
                { '$ref' => '#/definitions/stringPattern' },
                { '$ref' => '#/definitions/rulePattern' },
                {
                  'type' => 'object',
                  'properties' => {
                    # unfortunately this repetition is necessary to use additionalProperties: false
                    'name' => true, 'names' => true,
                    'has_prefix' => true, 'has_suffix' => true, 'matches' => true,
                    'path' => true, 'paths' => true,
                    'has_argument' => true, 'has_arguments' => true,
                    'unless' => { '$ref' => '#/definitions/keepTestOnlyList' }
                  },
                  'additionalProperties' => false,
                  'minProperties' => 1
                }
              ]
            }
          ]
        },
        'keepTestOnlyList' => {
          'anyOf' => [
            {
              'type' => 'array',
              'items' => { '$ref' => '#/definitions/keepTestOnly' },
              'minItems' => 1,
              'uniqueItems' => true
            },
            { '$ref' => '#/definitions/keepTestOnly' }
          ]
        }
      },
      'properties' => {
        'include_paths' => { '$ref' => '#/definitions/stringList' },
        'exclude_paths' => { '$ref' => '#/definitions/stringList' },
        'test_paths' => { '$ref' => '#/definitions/stringList' },
        'haml_paths' => { '$ref' => '#/definitions/stringList' },
        'erb_paths' => { '$ref' => '#/definitions/stringList' },
        'requires' => { '$ref' => '#/definitions/stringList' },
        'gems' => { '$ref' => '#/definitions/stringList' },
        'keep' => { '$ref' => '#/definitions/keepTestOnlyList' },
        'test_only' => { '$ref' => '#/definitions/keepTestOnlyList' },
        'dynamic' => { '$ref' => '#/definitions/dynamicList' }
      }
    }.freeze
  end
end

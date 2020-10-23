# frozen_string_literal: true

require_relative 'argument'
require_relative 'key'
require_relative 'itself'
require_relative 'value'

require_relative 'each_action'

require_relative 'transform_set'

module Leftovers
  module ProcessorBuilders
    module Action
      def self.build(patterns, action)
        ::Leftovers::ProcessorBuilders::EachAction.each_or_self(patterns) do |pattern|
          case pattern
          when nil then nil
          when ::String, ::Integer
            ::Leftovers::ProcessorBuilders::Argument.build(args, final_transformer(action))
          when ::Hash
            build_from_hash_value(pattern, action)
          else raise
          end
        end
      end

      def self.final_transformer(action)
        ::Leftovers::ProcessorBuilders::TransformSet.build(nil, action)
      end

      def self.build_from_hash_value(pattern, action)
        if pattern[:match] || pattern[:has_prefix] || pattern[:has_suffix]
          ::Leftovers::ProcessorBuilders::Argument.build(pattern, final_transformer(action))
        else
          build_action_from_hash_value(pattern, action)
        end
      end

      def self.build_action_from_hash_value(pattern, action) # rubocop:disable Metrics/MethodLength
        args = pattern.delete(:arguments)
        keys = pattern.delete(:keys)
        itself = pattern.delete(:itself)
        value = pattern.delete(:value)
        nested = pattern.delete(:nested)

        transformer = ::Leftovers::ProcessorBuilders::TransformSet.build(pattern, action)
        if nested
          transformer = ::Leftovers::ProcessorBuilders::EachValue.build([
            ::Leftovers::ProcessorBuilders::Action.build(nested, action),
            transformer
          ])
        end

        ::Leftovers::ProcessorBuilders::EachAction.build([
          ::Leftovers::ProcessorBuilders::Argument.build(args, transformer),
          ::Leftovers::ProcessorBuilders::Key.build(keys, transformer),
          ::Leftovers::ProcessorBuilders::Itself.build(itself, transformer),
          ::Leftovers::ProcessorBuilders::Value.build(value, transformer)
        ])
      end
    end
  end
end

# frozen_string_literal: true

module Leftovers
  module ProcessorBuilders
    module Action
      def self.build(patterns, action)
        ::Leftovers::ProcessorBuilders::EachAction.each_or_self(patterns) do |pattern|
          case pattern
          when ::String, ::Integer
            ::Leftovers::ProcessorBuilders::Argument.build(pattern, final_transformer(action))
          when ::Hash
            build_from_hash_value(action, **pattern)
          # :nocov:
          else raise Leftovers::UnexpectedCase, "Unhandled value #{pattern.inspect}"
            # :nocov:
          end
        end
      end

      def self.final_transformer(action)
        ::Leftovers::ProcessorBuilders::TransformSet.build_final(action)
      end

      def self.build_from_hash_value( # rubocop:disable Metrics/MethodLength, Metrics/ParameterLists
        action,
        arguments: nil,
        keywords: nil,
        itself: nil,
        value: nil,
        nested: nil,
        recursive: nil,
        **transform_args
      )
        transformer = ::Leftovers::ProcessorBuilders::TransformSet.build(transform_args, action)
        if nested
          transformer = ::Leftovers::ProcessorBuilders::Each.build([
            ::Leftovers::ProcessorBuilders::Action.build(nested, action),
            transformer
          ])
        end

        if recursive
          placeholder = ::Leftovers::ValueProcessors::Placeholder.new
          transformer = ::Leftovers::ProcessorBuilders::Each.build(
            [placeholder, transformer]
          )
        end

        processor = ::Leftovers::ProcessorBuilders::EachAction.build([
          ::Leftovers::ProcessorBuilders::Argument.build(arguments, transformer),
          ::Leftovers::ProcessorBuilders::Keyword.build(keywords, transformer),
          ::Leftovers::ProcessorBuilders::Itself.build(itself, transformer),
          ::Leftovers::ProcessorBuilders::Value.build(value, transformer)
        ])

        return processor unless recursive

        placeholder.processor = processor
        placeholder
      end
    end
  end
end

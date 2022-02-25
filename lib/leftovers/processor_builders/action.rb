# frozen_string_literal: true

module Leftovers
  module ProcessorBuilders
    module Action
      class << self
        def build(patterns, action)
          ::Leftovers::ProcessorBuilders::EachAction.each_or_self(patterns) do |pattern|
            case pattern
            when ::String, ::Integer
              ::Leftovers::ProcessorBuilders::Argument.build(pattern, final_transformer(action))
            when ::Hash then build_from_hash_value(action, **pattern)
            # :nocov:
            else raise Leftovers::UnexpectedCase, "Unhandled value #{pattern.inspect}"
              # :nocov:
            end
          end
        end

        private

        def final_transformer(action)
          ::Leftovers::ProcessorBuilders::TransformSet.build_final(action)
        end

        def build_nested(nested, transformer, action)
          ::Leftovers::ProcessorBuilders::Each.build([
            ::Leftovers::ProcessorBuilders::Action.build(nested, action),
            transformer
          ])
        end

        def build_processor(arguments, keywords, itself, value, transformer)
          ::Leftovers::ProcessorBuilders::EachAction.build([
            ::Leftovers::ProcessorBuilders::Argument.build(arguments, transformer),
            ::Leftovers::ProcessorBuilders::Keyword.build(keywords, transformer),
            ::Leftovers::ProcessorBuilders::Itself.build(itself, transformer),
            ::Leftovers::ProcessorBuilders::Value.build(value, transformer)
          ])
        end

        def build_recursive(transformer)
          placeholder = ::Leftovers::ValueProcessors::Placeholder.new
          transformer = ::Leftovers::ProcessorBuilders::Each.build([placeholder, transformer])

          [placeholder, transformer]
        end

        def build_from_hash_value( # rubocop:disable Metrics/ParameterLists
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
          transformer = build_nested(nested, transformer, action) if nested
          placeholder, transformer = build_recursive(transformer) if recursive
          processor = build_processor(arguments, keywords, itself, value, transformer)

          return processor unless recursive

          placeholder.processor = processor
          placeholder
        end
      end
    end
  end
end

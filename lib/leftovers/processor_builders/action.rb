# frozen_string_literal: true

module Leftovers
  module ProcessorBuilders
    module Action
      class << self
        def build(patterns, final_processor)
          ::Leftovers::ProcessorBuilders::Each.each_or_self(patterns) do |pattern|
            case pattern
            when ::String, ::Integer
              ::Leftovers::ProcessorBuilders::Argument.build(pattern, final_processor)
            when ::Hash then build_from_hash_value(**pattern, final_processor: final_processor)
            # :nocov:
            else raise Leftovers::UnexpectedCase, "Unhandled value #{pattern.inspect}"
              # :nocov:
            end
          end
        end

        def build_from_hash_value( # rubocop:disable Metrics/ParameterLists
          final_processor:,
          arguments: nil,
          keywords: nil,
          itself: nil,
          value: nil,
          nested: nil,
          recursive: nil,
          **transform_args
        )
          processor = ::Leftovers::ProcessorBuilders::TransformSet.build(
            transform_args, final_processor
          )
          processor = build_nested(nested, processor, final_processor) if nested
          recursive_placeholder, processor = build_recursive(processor) if recursive
          processor = build_sources(arguments, keywords, itself, value, processor)

          return processor unless recursive

          recursive_placeholder.processor = processor
          recursive_placeholder
        end

        private

        def build_nested(nested, processor, final_processor)
          ::Leftovers::ProcessorBuilders::Each.build([
            ::Leftovers::ProcessorBuilders::Action.build(nested, final_processor),
            processor
          ])
        end

        def build_sources(arguments, keywords, itself, value, processor)
          ::Leftovers::ProcessorBuilders::Each.build([
            ::Leftovers::ProcessorBuilders::Argument.build(arguments, processor),
            ::Leftovers::ProcessorBuilders::Keyword.build(keywords, processor),
            ::Leftovers::ProcessorBuilders::Itself.build(itself, processor),
            ::Leftovers::ProcessorBuilders::Value.build(value, processor)
          ])
        end

        def build_recursive(processor)
          recursive_placeholder = ::Leftovers::ValueProcessors::Placeholder.new
          processor = ::Leftovers::ProcessorBuilders::Each.build([recursive_placeholder, processor])

          [recursive_placeholder, processor]
        end
      end
    end
  end
end

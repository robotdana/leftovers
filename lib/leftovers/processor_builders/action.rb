# frozen_string_literal: true

module Leftovers
  module ProcessorBuilders
    module Action
      class << self
        def build(patterns, final_processor)
          Each.each_or_self(patterns) do |pattern|
            case pattern
            when ::String, ::Integer then Argument.build(pattern, final_processor)
            when ::Hash then build_from_hash_value(**pattern, final_processor: final_processor)
            # :nocov:
            else raise UnexpectedCase, "Unhandled value #{pattern.inspect}"
              # :nocov:
            end
          end
        end

        def build_from_hash_value( # rubocop:disable Metrics/ParameterLists
          final_processor:,
          arguments: nil,
          keywords: nil,
          itself: nil,
          receiver: nil,
          value: nil,
          nested: nil,
          recursive: nil,

          has_arguments: nil,
          has_receiver: nil,
          unless_arg: nil, all: nil, any: nil,
          **transform_args
        )
          processor = TransformSet.build(
            transform_args, final_processor
          )
          processor = build_nested(nested, processor) if nested
          recursive_placeholder, processor = build_recursive(processor) if recursive
          processor = build_sources(arguments, keywords, itself, receiver, value, processor)
          processor = build_matcher(has_arguments, has_receiver, unless_arg, all, any, processor)
          return processor unless recursive

          recursive_placeholder.processor = processor
          recursive_placeholder
        end

        private

        def build_nested(nested, processor)
          Each.build([Action.build(nested, processor), processor])
        end

        def build_sources(arguments, keywords, itself, receiver, value, processor) # rubocop:disable Metrics/ParameterLists
          Each.build([
            Argument.build(arguments, processor),
            Keyword.build(keywords, processor),
            Itself.build(itself, processor),
            Receiver.build(receiver, processor),
            Value.build(value, processor)
          ])
        end

        def build_recursive(processor)
          recursive_placeholder = Processors::Placeholder.new
          processor = Each.build([recursive_placeholder, processor])

          [recursive_placeholder, processor]
        end

        def build_matcher(has_arguments, has_receiver, unless_arg, all, any, processor) # rubocop:disable Metrics/ParameterLists
          matcher = MatcherBuilders::Node.build_from_hash(
            has_arguments: has_arguments,
            has_receiver: has_receiver,
            unless_arg: unless_arg,
            all: all,
            any: any
          )

          return processor unless matcher

          Processors::MatchMatchedNode.new(matcher, processor)
        end
      end
    end
  end
end

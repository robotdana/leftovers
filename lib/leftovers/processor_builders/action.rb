# frozen_string_literal: true

module Leftovers
  module ProcessorBuilders
    module Action
      def self.build(patterns, action)
        ::Leftovers::ProcessorBuilders::EachAction.each_or_self(patterns) do |pattern|
          case pattern
          when nil then nil
          when ::String, ::Integer
            ::Leftovers::ProcessorBuilders::Argument.build(pattern, final_transformer(action))
          when ::Hash
            build_from_hash_value(pattern, action)
          # :nocov:
          else raise
            # :nocov:
          end
        end
      end

      def self.final_transformer(action)
        ::Leftovers::ProcessorBuilders::TransformSet.build_final(action)
      end

      def self.build_from_hash_value(pattern, action) # rubocop:disable Metrics/PerceivedComplexity, Metrics/CyclomaticComplexity
        if pattern[:match] || pattern[:has_prefix] || pattern[:has_suffix]
          ::Leftovers::ProcessorBuilders::Argument.build(pattern, final_transformer(action))
        elsif pattern[:arguments] || pattern[:keywords] || pattern[:itself] || pattern[:value]
          build_action_from_hash_value(pattern, action)
        # :nocov:
        else raise
          # :nocov:
        end
      end

      def self.build_action_from_hash_value(pattern, action) # rubocop:disable Metrics/MethodLength, Metrics/AbcSize
        args = pattern.delete(:arguments)
        keywords = pattern.delete(:keywords)
        itself = pattern.delete(:itself)
        value = pattern.delete(:value)
        nested = pattern.delete(:nested)
        recursive = pattern.delete(:recursive)

        transformer = ::Leftovers::ProcessorBuilders::TransformSet.build(pattern, action)
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
          ::Leftovers::ProcessorBuilders::Argument.build(args, transformer),
          ::Leftovers::ProcessorBuilders::Keyword.build(keywords, transformer),
          ::Leftovers::ProcessorBuilders::Itself.build(itself, transformer),
          ::Leftovers::ProcessorBuilders::Value.build(value, transformer)
        ])

        return unless processor
        return processor unless recursive

        placeholder.processor = processor
        placeholder
      end
    end
  end
end

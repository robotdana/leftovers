# frozen_string_literal: true

module Leftovers
  module ProcessorBuilders
    module Argument
      def self.build(patterns, then_processor) # rubocop:disable Metrics/MethodLength
        ::Leftovers::ProcessorBuilders::EachAction.each_or_self(patterns) do |pattern|
          case pattern
          when ::Integer
            ::Leftovers::ValueProcessors::PositionalArgument.new(pattern - 1, then_processor)
          when '*'
            ::Leftovers::ValueProcessors::EachPositionalArgument.new(then_processor)
          when '**'
            ::Leftovers::ValueProcessors::EachKeywordArgument.new(then_processor)
          when ::String, ::Hash
            ::Leftovers::ProcessorBuilders::KeywordArgument.build(pattern, then_processor)
            # :nocov:
          else raise
            # :nocov:
          end
        end
      end
    end
  end
end

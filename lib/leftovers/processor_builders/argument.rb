# frozen_string_literal: true

module Leftovers
  module ProcessorBuilders
    module Argument
      def self.build(patterns, then_processor) # rubocop:disable Metrics/MethodLength
        return unless then_processor

        ::Leftovers::ProcessorBuilders::EachAction.each_or_self(patterns) do |pattern|
          case pattern
          when nil then nil
          when ::Integer
            ::Leftovers::ValueProcessors::PositionalArgument.new(pattern - 1, then_processor)
          when '*'
            ::Leftovers::ValueProcessors::EachPositionalArgument.new(then_processor)
          when '**'
            ::Leftovers::ValueProcessors::EachKeywordArgument.new(then_processor)
          when ::String, ::Hash
            ::Leftovers::ProcessorBuilders::KeywordArgument.build(pattern, then_processor)
          else
            raise 'not done yet'
          end
        end
      end
    end
  end
end

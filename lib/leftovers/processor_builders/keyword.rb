# frozen_string_literal: true

module Leftovers
  module ProcessorBuilders
    module Keyword
      def self.build(value, then_processor) # rubocop:disable Metrics/MethodLength
        return unless value && then_processor

        case value
        when true, '**'
          ::Leftovers::ValueProcessors::EachKeyword.new(then_processor)
        when ::String, ::Hash, ::Array
          ::Leftovers::ValueProcessors::Keyword.new(
            ::Leftovers::MatcherBuilders::NodePairName.build(value),
            then_processor
          )
        # :nocov:
        else raise
          # :nocov:
        end
      end
    end
  end
end

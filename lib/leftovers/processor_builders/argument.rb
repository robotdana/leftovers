# frozen_string_literal: true

module Leftovers
  module ProcessorBuilders
    module Argument
      class << self
        def build(patterns, processor) # rubocop:disable Metrics/MethodLength
          ::Leftovers::ProcessorBuilders::Each.each_or_self(patterns) do |pat|
            case pat
            when ::Integer then ::Leftovers::Processors::PositionalArgument.new(pat, processor)
            when '*' then ::Leftovers::Processors::EachPositionalArgument.new(processor)
            when '**' then ::Leftovers::Processors::EachKeywordArgument.new(processor)
            when /\A(\d+)\+\z/
              ::Leftovers::Processors::EachPositionalArgumentFrom.new(pat.to_i, processor)
            when ::String
              ::Leftovers::ProcessorBuilders::KeywordArgument.build(pat, processor)
            when ::Hash
              build_hash(processor, pat)
              # :nocov:
            else raise Leftovers::UnexpectedCase, "Unhandled value #{pat.inspect}"
              # :nocov:
            end
          end
        end

        private

        def build_hash(then_processor, pat)
          ::Leftovers::Processors::KeywordArgument.new(
            ::Leftovers::MatcherBuilders::NodePairKey.build(
              ::Leftovers::MatcherBuilders::Node.build_from_hash(**pat)
            ),
            then_processor
          )
        end
      end
    end
  end
end

# frozen_string_literal: true

module Leftovers
  module ProcessorBuilders
    module Argument
      class << self
        def build(patterns, processor) # rubocop:disable Metrics/MethodLength
          Each.each_or_self(patterns) do |pat|
            case pat
            when ::Integer then Processors::PositionalArgument.new(pat, processor)
            when '*' then Processors::EachPositionalArgument.new(processor)
            when '**' then Processors::EachKeywordArgument.new(processor)
            when /\A(\d+)\+\z/
              Processors::EachPositionalArgumentFrom.new(pat.to_i, processor)
            when ::String
              KeywordArgument.build(pat, processor)
            when ::Hash
              build_hash(processor, pat)
              # :nocov:
            else raise UnexpectedCase, "Unhandled value #{pat.inspect}"
              # :nocov:
            end
          end
        end

        private

        def build_hash(then_processor, pat)
          Processors::KeywordArgument.new(
            MatcherBuilders::NodePairKey.build(MatcherBuilders::Node.build_from_hash(**pat)),
            then_processor
          )
        end
      end
    end
  end
end

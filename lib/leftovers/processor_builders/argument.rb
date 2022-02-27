# frozen_string_literal: true

module Leftovers
  module ProcessorBuilders
    module Argument
      def self.build(patterns, processor)
        ::Leftovers::ProcessorBuilders::Each.each_or_self(patterns) do |pat|
          case pat
          when ::Integer then ::Leftovers::ValueProcessors::PositionalArgument.new(pat, processor)
          when '*' then ::Leftovers::ValueProcessors::EachPositionalArgument.new(processor)
          when '**' then ::Leftovers::ValueProcessors::EachKeywordArgument.new(processor)
          when ::String, ::Hash
            ::Leftovers::ProcessorBuilders::KeywordArgument.build(pat, processor)
            # :nocov:
          else raise Leftovers::UnexpectedCase, "Unhandled value #{pat.inspect}"
            # :nocov:
          end
        end
      end
    end
  end
end

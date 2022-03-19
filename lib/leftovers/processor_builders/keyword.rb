# frozen_string_literal: true

module Leftovers
  module ProcessorBuilders
    module Keyword
      def self.build(value, then_processor)
        return unless value

        then_processor = case value
        when true, '**' then then_processor
        when ::String, ::Hash, ::Array
          Processors::MatchCurrentNode.new(
            MatcherBuilders::NodeName.build(value), then_processor
          )
        # :nocov:
        else raise UnexpectedCase, "Unhandled value #{value.inspect}"
          # :nocov:
        end

        Processors::EachKeyword.new(then_processor)
      end
    end
  end
end

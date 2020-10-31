# frozen_string_literal: true

module Leftovers
  module MatcherBuilders
    module Name
      def self.build(patterns) # rubocop:disable Metrics/MethodLength
        ::Leftovers::MatcherBuilders::Or.each_or_self(patterns) do |pat|
          case pat
          when nil
          when ::Array
            ::Leftovers::MatcherBuilders::Name.build(pat)
          when ::String
            ::Leftovers::MatcherBuilders::String.build(pat)
          when ::Hash
            unless_arg = pat.delete(:unless_arg)

            ::Leftovers::MatcherBuilders::AndNot.build(
              ::Leftovers::MatcherBuilders::StringPattern.build(**pat),
              ::Leftovers::MatcherBuilders::Name.build(unless_arg)
            )
          # :nocov:
          else raise
            # :nocov:
          end
        end
      end
    end
  end
end

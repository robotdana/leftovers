# frozen_string_literal: true

module Leftovers
  module MatcherBuilders
    module Name
      class << self
        def build(patterns)
          ::Leftovers::MatcherBuilders::Or.each_or_self(patterns) do |pat|
            case pat
            when ::String then ::Leftovers::MatcherBuilders::String.build(pat)
            when ::Hash then build_from_hash(**pat)
            # :nocov:
            else raise Leftovers::UnexpectedCase, "Unhandled value #{pat.inspect}"
              # :nocov:
            end
          end
        end

        private

        def build_from_hash(unless_arg: nil, **pattern)
          ::Leftovers::MatcherBuilders::AndNot.build(
            ::Leftovers::MatcherBuilders::StringPattern.build(**pattern),
            ::Leftovers::MatcherBuilders::Name.build(unless_arg)
          )
        end
      end
    end
  end
end

# frozen_string_literal: true

module Leftovers
  module MatcherBuilders
    module Name
      class << self
        def build(patterns)
          Or.each_or_self(patterns) do |pat|
            case pat
            when ::String then String.build(pat)
            when ::Hash then build_from_hash(**pat)
            # :nocov:
            else raise UnexpectedCase, "Unhandled value #{pat.inspect}"
              # :nocov:
            end
          end
        end

        private

        def build_from_hash(unless_arg: nil, **pattern)
          And.build([StringPattern.build(**pattern), Unless.build(build(unless_arg))])
        end
      end
    end
  end
end

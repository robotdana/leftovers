# frozen_string_literal: true

require_relative 'or'
require_relative 'and'
require_relative 'unless'
require_relative 'string'
require_relative 'string_pattern'

module Leftovers
  module MatcherBuilders
    module Name
      def self.build(patterns) # rubocop:disable Metrics/MethodLength
        ::Leftovers::MatcherBuilders::Or.each_or_self(patterns) do |pat|
          case pat
          when ::String
            ::Leftovers::MatcherBuilders::String.build(pat)
          when ::Hash
            ::Leftovers::MatcherBuilders::And.build([
              ::Leftovers::MatcherBuilders::Unless.build(
                ::Leftovers::MatcherBuilders::Name.build(pat.delete(:unless_arg))
              ),
              ::Leftovers::MatcherBuilders::StringPattern.build(**pat)
            ])
          end
        end
      end
    end
  end
end

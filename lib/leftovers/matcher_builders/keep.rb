# frozen_string_literal: true

module Leftovers
  module MatcherBuilders
    module Keep
      def self.build(patterns)
        ::Leftovers::MatcherBuilders::Or.each_or_self(patterns) do |pattern|
          case pattern
          when ::String
            ::Leftovers::MatcherBuilders::NodeName.build(pattern)
          when ::Hash
            build_hash_value(pattern)
          # :nocov:
          else raise
            # :nocov:
          end
        end
      end

      def self.build_hash_value(pattern)
        if pattern[:names] || pattern[:paths] || pattern[:has_arguments]
          ::Leftovers::MatcherBuilders::Dynamic.build(**pattern)
        elsif pattern[:match] || pattern[:has_prefix] || pattern[:has_suffix]
          ::Leftovers::MatcherBuilders::NodeName.build(pattern)
        # :nocov:
        else raise
          # :nocov:
        end
      end
    end
  end
end

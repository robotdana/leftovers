# frozen_string_literal: true

require_relative 'node_name'
require_relative 'rule'
require_relative 'or'

module Leftovers
  module MatcherBuilders
    module Keep
      def self.build(patterns) # rubocop:disable Metrics/MethodLength
        ::Leftovers::MatcherBuilders::Or.each_or_self(patterns) do |pattern|
          case pattern
          when ::String
            ::Leftovers::MatcherBuilders::NodeName.build(pattern)
          when ::Hash
            build_hash_value(pattern)
          end
        end
      end

      def self.build_hash_value(pattern) # rubocop:disable Metrics/MethodLength
        if pattern[:names] || pattern[:paths] || pattern[:has_arguments]
          ::Leftovers::MatcherBuilders::Rule.build(**pattern)
        elsif pattern[:match] || pattern[:has_prefix] || pattern[:has_suffix]
          ::Leftovers::MatcherBuilders::NodeName.build(pattern)
        else raise 'Invalid value'
        end
      end
    end
  end
end

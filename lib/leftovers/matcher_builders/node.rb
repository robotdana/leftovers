# frozen-string-literal: true

require_relative '../matchers/node_scalar_value'
require_relative '../matchers/node_name'
require_relative 'node_name'
require_relative 'node_type'
require_relative 'or'

module Leftovers
  module MatcherBuilders
    module Node
      def self.build(pattern, default) # rubocop:disable Metrics/MethodLength
        ::Leftovers::MatcherBuilders::Or.each_or_self(pattern, default) do |pat|
          case pat
          when ::Integer, true, false, nil
            ::Leftovers::Matchers::NodeScalarValue.new(pat)
          when ::String
            ::Leftovers::MatcherBuilders::NodeName.build(pat, nil)
          when ::Hash
            build_from_hash(**pat)
          end
        end
      end

      def self.build_from_hash(type: nil, unless_arg: nil) # rubocop:disable Metrics/MethodLength
        type_matcher = ::Leftovers::MatcherBuilders::NodeType.build(type, nil)

        not_matcher = if unless_arg
          ::Leftovers::Matchers::Not.new(
            ::Leftovers::MatcherBuilders::Node.build(unless_arg)
          )
        end

        ::Leftovers::MatcherBuilders::And.build([type_matcher, not_matcher], nil)
      end
    end
  end
end

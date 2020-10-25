# frozen-string-literal: true

module Leftovers
  module MatcherBuilders
    module Node
      def self.build(pattern) # rubocop:disable Metrics/MethodLength
        ::Leftovers::MatcherBuilders::Or.each_or_self(pattern) do |pat|
          case pat
          when ::Integer, true, false, nil
            ::Leftovers::Matchers::NodeScalarValue.new(pat)
          when ::String
            ::Leftovers::MatcherBuilders::NodeName.build(pat)
          when ::Hash
            build_from_hash(**pat)
          # :nocov:
          else raise
            # :nocov:
          end
        end
      end

      def self.build_from_hash(type: nil, unless_arg: nil)
        ::Leftovers::MatcherBuilders::AndNot.build(
          ::Leftovers::MatcherBuilders::NodeType.build(type),
          ::Leftovers::MatcherBuilders::Node.build(unless_arg)
        )
      end
    end
  end
end

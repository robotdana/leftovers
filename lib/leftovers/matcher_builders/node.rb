# frozen-string-literal: true

module Leftovers
  module MatcherBuilders
    module Node
      def self.build(pattern)
        ::Leftovers::MatcherBuilders::Or.each_or_self(pattern) do |pat|
          case pat
          when ::Integer, true, false, nil
            ::Leftovers::Matchers::NodeScalarValue.new(pat)
          when ::String
            ::Leftovers::MatcherBuilders::NodeName.build(pat)
          when ::Hash
            build_from_hash(**pat)
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

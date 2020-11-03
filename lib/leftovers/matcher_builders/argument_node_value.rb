# frozen-string-literal: true

module Leftovers
  module MatcherBuilders
    module ArgumentNodeValue
      def self.build(pattern)
        ::Leftovers::MatcherBuilders::Or.each_or_self(pattern) do |pat|
          case pat
          when ::Integer, true, false, nil
            ::Leftovers::Matchers::NodeScalarValue.new(pat)
          when ::String, ::Hash
            ::Leftovers::MatcherBuilders::NodeName.build(pat)
          # :nocov:
          else raise
            # :nocov:
          end
        end
      end
    end
  end
end

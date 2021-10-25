# frozen-string-literal: true

module Leftovers
  module MatcherBuilders
    module NodeValue
      class << self
        def build(pattern) # rubocop:disable Metrics/MethodLength
          ::Leftovers::MatcherBuilders::Or.each_or_self(pattern) do |pat|
            case pat
            when ::Integer, true, false, nil
              ::Leftovers::Matchers::NodeScalarValue.new(pat)
            when ::String
              ::Leftovers::MatcherBuilders::NodeName.build(pat)
            when ::Hash
              build_from_hash(pat)
            # :nocov:
            else raise
              # :nocov:
            end
          end
        end

        private

        def build_from_hash(pat) # rubocop:disable Metrics/MethodLength
          matcher = ::Leftovers::MatcherBuilders::And.build([
            ::Leftovers::MatcherBuilders::NodeHasArgument.build(pat.slice(:at, :has_value)),
            ::Leftovers::MatcherBuilders::NodeName.build(
              pat.slice(:match, :has_prefix, :has_suffix)
            ),
            ::Leftovers::MatcherBuilders::NodeType.build(pat[:type]),
            ::Leftovers::MatcherBuilders::NodeHasReceiver.build(pat[:has_receiver])
          ])

          ::Leftovers::MatcherBuilders::AndNot.build(
            matcher, ::Leftovers::MatcherBuilders::NodeValue.build(pat[:unless_arg])
          )
        end
      end
    end
  end
end

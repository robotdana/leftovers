# frozen-string-literal: true

module Leftovers
  module MatcherBuilders
    module ArgumentNodeValue
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
          matcher = if pat.key?(:at) || pat.key?(:has_value)
            ::Leftovers::MatcherBuilders::NodeHasArgument.build({ **pat, unless_arg: nil })
          elsif pat.key?(:match) || pat.key?(:has_prefix) || pat.key?(:has_suffix)
            ::Leftovers::MatcherBuilders::NodeName.build({ **pat, unless_arg: nil })
          elsif pat.key?(:type)
            ::Leftovers::MatcherBuilders::NodeType.build(pat[:type])
            # :nocov:
          else raise
            # :nocov:
          end

          ::Leftovers::MatcherBuilders::AndNot.build(
            matcher, ::Leftovers::MatcherBuilders::ArgumentNodeValue.build(pat[:unless_arg])
          )
        end
      end
    end
  end
end

# frozen-string-literal: true

module Leftovers
  module MatcherBuilders
    module NodeValue
      class << self
        def build(patterns)
          ::Leftovers::MatcherBuilders::Or.each_or_self(patterns) do |pattern|
            case pattern
            when ::Integer, ::Float, true, false, nil
              ::Leftovers::Matchers::NodeScalarValue.new(pattern)
            when ::String then ::Leftovers::MatcherBuilders::NodeName.build(pattern)
            when ::Hash then build_from_hash(**pattern)
            # :nocov:
            else raise Leftovers::UnexpectedCase, "Unhandled value #{pattern.inspect}"
              # :nocov:
            end
          end
        end

        private

        def build_node_name(match, has_prefix, has_suffix)
          ::Leftovers::MatcherBuilders::NodeName.build(
            match: match, has_prefix: has_prefix, has_suffix: has_suffix
          )
        end

        def build_unless(unless_arg)
          return unless unless_arg

          ::Leftovers::MatcherBuilders::Unless.build(
            ::Leftovers::MatcherBuilders::NodeValue.build(unless_arg)
          )
        end

        def build_from_hash( # rubocop:disable Metrics/ParameterLists
          at: nil, has_value: nil,
          match: nil, has_prefix: nil, has_suffix: nil,
          type: nil,
          has_receiver: nil,
          unless_arg: nil
        )
          ::Leftovers::MatcherBuilders::And.build([
            ::Leftovers::MatcherBuilders::NodeHasArgument.build(at: at, has_value: has_value),
            build_node_name(match, has_prefix, has_suffix),
            ::Leftovers::MatcherBuilders::NodeType.build(type),
            ::Leftovers::MatcherBuilders::NodeHasReceiver.build(has_receiver),
            build_unless(unless_arg)
          ])
        end
      end
    end
  end
end

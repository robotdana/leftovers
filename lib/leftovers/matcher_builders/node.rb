# frozen-string-literal: true

module Leftovers
  module MatcherBuilders
    module Node
      class << self
        def build(patterns)
          ::Leftovers::MatcherBuilders::Or.each_or_self(patterns) do |pattern|
            case pattern
            when ::String then ::Leftovers::MatcherBuilders::NodeName.build(pattern)
            when ::Hash then build_from_hash(**pattern)
              # :nocov:
            else raise Leftovers::UnexpectedCase, "Unhandled value #{pattern.inspect}"
              # :nocov:
            end
          end
        end

        def build_from_hash( # rubocop:disable Metrics/ParameterLists
          names: nil, match: nil, has_prefix: nil, has_suffix: nil,
          document: false,
          paths: nil,
          has_arguments: nil,
          has_receiver: nil,
          type: nil,
          privacy: nil,
          unless_arg: nil, all: nil, any: nil
        )
          ::Leftovers::MatcherBuilders::And.build([
            build_node_name_matcher(names, match, has_prefix, has_suffix),
            ::Leftovers::MatcherBuilders::Document.build(document),
            ::Leftovers::MatcherBuilders::NodePath.build(paths),
            ::Leftovers::MatcherBuilders::NodeHasArgument.build(has_arguments),
            ::Leftovers::MatcherBuilders::NodeHasReceiver.build(has_receiver),
            ::Leftovers::MatcherBuilders::NodePrivacy.build(privacy),
            ::Leftovers::MatcherBuilders::NodeType.build(type),
            build_unless_matcher(unless_arg), build_all_matcher(all), build_any_matcher(any)
          ])
        end

        private

        def build_node_name_matcher(names, match, has_prefix, has_suffix)
          ::Leftovers::MatcherBuilders::Or.build([
            ::Leftovers::MatcherBuilders::NodeName.build(names),
            ::Leftovers::MatcherBuilders::NodeName.build(
              match: match, has_prefix: has_prefix, has_suffix: has_suffix
            )
          ])
        end

        def build_unless_matcher(unless_arg)
          return unless unless_arg

          ::Leftovers::MatcherBuilders::Unless.build(
            ::Leftovers::MatcherBuilders::Node.build(unless_arg)
          )
        end

        def build_all_matcher(all)
          return unless all

          ::Leftovers::MatcherBuilders::And.build(
            all.map { |pattern| ::Leftovers::MatcherBuilders::Node.build(pattern) }
          )
        end

        def build_any_matcher(any)
          ::Leftovers::MatcherBuilders::Node.build(any)
        end
      end
    end
  end
end

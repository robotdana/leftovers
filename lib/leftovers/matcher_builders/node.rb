# frozen_string_literal: true

module Leftovers
  module MatcherBuilders
    module Node
      class << self
        def build(patterns)
          Or.each_or_self(patterns) do |pattern|
            case pattern
            when ::String then NodeName.build(pattern)
            when ::Hash then build_from_hash(**pattern)
              # :nocov:
            else raise UnexpectedCase, "Unhandled value #{pattern.inspect}"
              # :nocov:
            end
          end
        end

        def build_from_hash( # rubocop:disable Metrics/ParameterLists, Metrics/MethodLength
          names: nil, match: nil, has_prefix: nil, has_suffix: nil,
          document: false,
          paths: nil,
          has_arguments: nil,
          has_receiver: nil,
          has_block: nil,
          type: nil,
          privacy: nil,
          unless_arg: nil, all: nil, any: nil
        )
          And.build([
            build_node_name_matcher(names, match, has_prefix, has_suffix),
            Document.build(document),
            NodePath.build(paths),
            NodeHasArgument.build(has_arguments),
            NodeHasBlock.build(has_block),
            NodeHasReceiver.build(has_receiver),
            NodePrivacy.build(privacy),
            NodeType.build(type),
            Unless.build(build(unless_arg)),
            build_all_matcher(all),
            build(any)
          ])
        end

        private

        def build_node_name_matcher(names, match, has_prefix, has_suffix)
          Or.build([
            NodeName.build(names),
            NodeName.build(match: match, has_prefix: has_prefix, has_suffix: has_suffix)
          ])
        end

        def build_all_matcher(all)
          And.build(all.map { |pattern| build(pattern) }) if all
        end
      end
    end
  end
end

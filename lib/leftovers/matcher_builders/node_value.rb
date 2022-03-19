# frozen-string-literal: true

module Leftovers
  module MatcherBuilders
    module NodeValue
      class << self
        def build(patterns)
          Or.each_or_self(patterns) do |pattern|
            case pattern
            when ::Integer, ::Float, true, false
              # matching scalar on nil will fall afoul of compact and each_or_self etc.
              Matchers::NodeScalarValue.new(pattern)
            when :_leftovers_nil_value then Matchers::NodeType.new(:nil)
            when ::String then NodeName.build(pattern)
            when ::Hash then build_from_hash(**pattern)
            # :nocov:
            else raise UnexpectedCase, "Unhandled value #{pattern.inspect}"
              # :nocov:
            end
          end
        end

        private

        def build_node_name_matcher(names, match, has_prefix, has_suffix)
          Or.build([
            NodeName.build(names),
            NodeName.build(match: match, has_prefix: has_prefix, has_suffix: has_suffix)
          ])
        end

        def build_node_has_argument_matcher(has_arguments, at, has_value)
          Or.build([
            NodeHasArgument.build(has_arguments),
            NodeHasArgument.build(at: at, has_value: has_value)
          ])
        end

        def build_unless(unless_arg)
          return unless unless_arg

          Unless.build(build(unless_arg))
        end

        def build_from_hash( # rubocop:disable Metrics/ParameterLists
          has_arguments: nil, at: nil, has_value: nil,
          names: nil, match: nil, has_prefix: nil, has_suffix: nil,
          type: nil,
          has_receiver: nil,
          literal: nil,
          unless_arg: nil
        )
          And.build([
            build_node_has_argument_matcher(has_arguments, at, has_value),
            build_node_name_matcher(names, match, has_prefix, has_suffix),
            NodeType.build(type),
            NodeHasReceiver.build(has_receiver),
            NodeValue.build(literal),
            build_unless(unless_arg)
          ])
        end
      end
    end
  end
end

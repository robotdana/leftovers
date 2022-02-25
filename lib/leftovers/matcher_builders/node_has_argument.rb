# frozen-string-literal: true

module Leftovers
  module MatcherBuilders
    module NodeHasArgument
      class << self
        def build(patterns)
          ::Leftovers::MatcherBuilders::Or.each_or_self(patterns) do |pat|
            case pat
            when ::String
              ::Leftovers::MatcherBuilders::NodeHasKeywordArgument.build(pat, nil)
            when ::Integer
              ::Leftovers::MatcherBuilders::NodeHasPositionalArgument.build(pat, nil)
            when ::Hash then build_from_hash(**pat)
            # :nocov:
            else raise Leftovers::UnexpectedCase, "Unhandled value #{pat.inspect}"
              # :nocov:
            end
          end
        end

        private

        def build_from_hash(at: nil, has_value: nil, unless_arg: nil)
          value_matcher = ::Leftovers::MatcherBuilders::NodeValue.build(has_value)

          ::Leftovers::MatcherBuilders::AndNot.build(
            build_argument_matcher(value_matcher, **separate_argument_types(at)),
            ::Leftovers::MatcherBuilders::NodeHasArgument.build(unless_arg)
          )
        end

        def separate_argument_types(at)
          groups = ::Leftovers.each_or_self(at).group_by do |index|
            case index
            when '*', ::Integer then :positions
            when ::String, ::Hash then :keys
            # :nocov:
            else raise Leftovers::UnexpectedCase, "Unhandled value #{index.inspect}"
              # :nocov:
            end
          end

          groups.transform_values { |v| Leftovers.unwrap_array(v) }
        end

        def build_has_keyword_argument(keys, value_matcher)
          ::Leftovers::MatcherBuilders::NodeHasKeywordArgument.build(keys, value_matcher)
        end

        def build_has_positional_argument(positions, value_matcher)
          ::Leftovers::MatcherBuilders::NodeHasPositionalArgument.build(positions, value_matcher)
        end

        def build_argument_matcher(value_matcher, keys: nil, positions: nil)
          if keys && !positions
            build_has_keyword_argument(keys, value_matcher)
          elsif positions && !keys
            build_has_positional_argument(positions, value_matcher)
          else
            ::Leftovers::MatcherBuilders::Or.build([
              build_has_positional_argument(positions, value_matcher),
              build_has_keyword_argument(keys, value_matcher)
            ])
          end
        end
      end
    end
  end
end

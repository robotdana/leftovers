# frozen-string-literal: true

module Leftovers
  module MatcherBuilders
    module NodeHasArgument
      class << self
        def build(patterns)
          Or.each_or_self(patterns) do |pat|
            case pat
            when ::String
              NodeHasKeywordArgument.build(pat, nil)
            when ::Integer
              NodeHasPositionalArgument.build(pat, nil)
            when ::Hash then build_from_hash(**pat)
            # :nocov:
            else raise UnexpectedCase, "Unhandled value #{pat.inspect}"
              # :nocov:
            end
          end
        end

        private

        def build_from_hash(at: nil, has_value: nil, unless_arg: nil)
          value_matcher = NodeValue.build(has_value)

          AndNot.build(
            build_argument_matcher(value_matcher, **separate_argument_types(at)),
            build(unless_arg)
          )
        end

        def separate_argument_types(at)
          groups = ::Leftovers.each_or_self(at).group_by do |index|
            case index
            when '*', ::Integer then :positions
            when ::String, ::Hash then :keys
            # :nocov:
            else raise UnexpectedCase, "Unhandled value #{index.inspect}"
              # :nocov:
            end
          end

          groups.transform_values { |v| ::Leftovers.unwrap_array(v) }
        end

        def build_has_keyword_argument(keys, value_matcher)
          NodeHasKeywordArgument.build(keys, value_matcher)
        end

        def build_has_positional_argument(positions, value_matcher)
          NodeHasPositionalArgument.build(positions, value_matcher)
        end

        def build_argument_matcher(value_matcher, keys: nil, positions: nil)
          if keys && !positions
            build_has_keyword_argument(keys, value_matcher)
          elsif positions && !keys
            build_has_positional_argument(positions, value_matcher)
          else
            Or.build([
              build_has_positional_argument(positions, value_matcher),
              build_has_keyword_argument(keys, value_matcher)
            ])
          end
        end
      end
    end
  end
end

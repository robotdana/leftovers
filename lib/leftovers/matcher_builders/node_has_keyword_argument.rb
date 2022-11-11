# frozen_string_literal: true

module Leftovers
  module MatcherBuilders
    module NodeHasKeywordArgument
      class << self
        def build(keywords, value_matcher)
          value_matcher = NodePairValue.build(value_matcher)
          keyword_matcher = build_keyword_matcher(keywords)
          pair_matcher = And.build([keyword_matcher, value_matcher])

          return unless pair_matcher

          Matchers::NodeHasAnyKeywordArgument.new(pair_matcher)
        end

        private

        def build_keyword_matcher(keywords)
          if ::Leftovers.wrap_array(keywords).include?('**')
            Matchers::NodeType.new(:pair)
          else
            NodePairKey.build(Node.build(keywords))
          end
        end
      end
    end
  end
end

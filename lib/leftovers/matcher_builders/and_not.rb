# frozen-string-literal: true

module Leftovers
  module MatcherBuilders
    module AndNot
      class << self
        def build(positive_matcher, negative_matcher)
          And.build([positive_matcher, Unless.build(negative_matcher)])
        end
      end
    end
  end
end

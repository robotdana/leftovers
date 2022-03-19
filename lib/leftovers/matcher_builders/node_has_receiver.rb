# frozen-string-literal: true

module Leftovers
  module MatcherBuilders
    module NodeHasReceiver
      class << self
        def build(pattern)
          case pattern
          when true
            Matchers::NodeHasAnyReceiver
          when false, :_leftovers_nil_value
            Matchers::Not.new(Matchers::NodeHasAnyReceiver)
          else
            matcher = NodeValue.build(pattern)

            Matchers::NodeHasReceiver.new(matcher) if matcher
          end
        end
      end
    end
  end
end

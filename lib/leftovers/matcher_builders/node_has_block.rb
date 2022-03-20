# frozen-string-literal: true

module Leftovers
  module MatcherBuilders
    module NodeHasBlock
      class << self
        def build(has_block)
          if has_block
            Matchers::NodeHasBlock
          elsif has_block == false
            Matchers::Not.new(Matchers::NodeHasBlock)
          end
        end
      end
    end
  end
end

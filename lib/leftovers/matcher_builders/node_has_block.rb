# frozen-string-literal: true

module Leftovers
  module MatcherBuilders
    module NodeHasBlock
      class << self
        def build(has_block)
          return if has_block.nil?

          if has_block
            Matchers::NodeHasBlock
          else
            Matchers::Not.new(Matchers::NodeHasBlock)
          end
        end
      end
    end
  end
end

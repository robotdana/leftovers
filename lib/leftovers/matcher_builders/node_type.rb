# frozen-string-literal: true

require 'set'

module Leftovers
  module MatcherBuilders
    module NodeType
      def self.build(types_pattern)
        matcher = ::Leftovers::MatcherBuilders::Or.each_or_self(types_pattern) do |type|
          case type
          when 'Symbol' then :sym
          when 'String' then :str
          when 'Integer' then :int
          when 'Float' then :float
          # these would be neat but i can't think of a use-case
          # when 'Array' then :array
          # when 'Hash' then :hash
          # when 'Method' then Set[:send, :csend, :def]
          # when 'Constant' then Set[:const, :class, :module]
          # :nocov:
          else raise
            # :nocov:
          end
        end

        ::Leftovers::Matchers::NodeType.new(matcher)
      end
    end
  end
end

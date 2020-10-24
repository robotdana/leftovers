# frozen-string-literal: true

require 'set'

module Leftovers
  module MatcherBuilders
    module NodeType
      def self.build(types_pattern) # rubocop:disable Metrics/MethodLength
        matcher = ::Leftovers::MatcherBuilders::Or.each_or_self(types_pattern) do |type|
          case type
          when 'Symbol' then :sym
          when 'String' then :str
          when 'Integer' then :int
          when 'Float' then :float
          when 'Method' then Set[:send, :csend, :def]
          when 'Constant' then Set[:const, :class, :const]
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

# frozen-string-literal: true

require 'set'

module Leftovers
  module MatcherBuilders
    module NodeType
      def self.build(types_pattern) # rubocop:disable Metrics/MethodLength
        ::Leftovers::MatcherBuilders::Or.each_or_self(types_pattern) do |type|
          case type
          when 'Symbol' then ::Leftovers::Matchers::NodeType.new(:sym)
          when 'String' then ::Leftovers::Matchers::NodeType.new(:str)
          when 'Integer' then ::Leftovers::Matchers::NodeType.new(:int)
          when 'Float' then ::Leftovers::Matchers::NodeType.new(:float)
          # these would be neat but i can't think of a use-case
          when 'Array' then ::Leftovers::Matchers::NodeType.new(:array)
          when 'Hash' then ::Leftovers::Matchers::NodeType.new(:hash)
          # when 'Method' then Set[:send, :csend, :def]
          # when 'Constant' then Set[:const, :class, :module]
          # :nocov:
          else raise
            # :nocov:
          end
        end
      end
    end
  end
end

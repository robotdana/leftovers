# frozen-string-literal: true

require 'set'

module Leftovers
  module MatcherBuilders
    module NodeType
      def self.build(types_pattern) # rubocop:disable Metrics/MethodLength, Metrics/CyclomaticComplexity
        ::Leftovers::MatcherBuilders::Or.each_or_self(types_pattern) do |type|
          case type
          when 'Symbol' then ::Leftovers::Matchers::NodeType.new(:sym)
          when 'String' then ::Leftovers::Matchers::NodeType.new(:str)
          when 'Integer' then ::Leftovers::Matchers::NodeType.new(:int)
          when 'Float' then ::Leftovers::Matchers::NodeType.new(:float)
          when 'Array' then ::Leftovers::Matchers::NodeType.new(:array)
          when 'Hash' then ::Leftovers::Matchers::NodeType.new(:hash)

          when 'Proc' then ::Leftovers::Matchers::Predicate.new(:proc?)
          # when 'Method' then ::Leftovers::Matchers::NodeType.new(Set[:send, :csend, :def])
          # when 'Constant' then ::Leftovers::Matchers::NodeType.new(Set[:const, :class, :module])
          # :nocov:
          else raise
            # :nocov:
          end
        end
      end
    end
  end
end

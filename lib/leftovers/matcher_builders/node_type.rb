# frozen-string-literal: true

require_relative 'fallback'
require_relative 'path'
require_relative '../matchers/node_type'

module Leftovers
  module MatcherBuilders
    module NodeType
      def self.build(types_pattern, default = true) # rubocop:disable Metrics/MethodLength, Metrics/CyclomaticComplexity
        matcher = ::Leftovers::MatcherBuilders::Or.each_or_self(types_pattern, nil) do |type|
          case type
          when 'Symbol' then :sym
          when 'String' then :str
          when 'Integer' then :int
          when 'Float' then :float
          when 'Method' then Set[:send, :csend, :def]
          when 'Constant' then Set[:const, :class, :const]
          else raise ::Leftovers::ConfigError, "Unrecognized type #{type}"
          end
        end

        return ::Leftovers::Matchers::NodeType.new(matcher) if matcher

        ::Leftovers::MatcherBuilders::Fallback.build(default)
      end
    end
  end
end

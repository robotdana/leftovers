# frozen-string-literal: true

require_relative 'fallback'
require_relative 'path'
require_relative '../matchers/node_type'

module Leftovers
  module MatcherBuilders
    module NodeType
      def self.build(types_pattern, default = true) # rubocop:disable Metrics/MethodLength, Metrics/CyclomaticComplexity
        types = []
        ::Leftovers.each_or_self(types_pattern) do |type|
          case type
          when 'Symbol' then types << :sym
          when 'String' then types << :str
          when 'Integer' then types << :int
          when 'Float' then types << :float
          when 'Method' then types << Set[:send, :csend, :def]
          when 'Constant' then types << Set[:const, :class, :const]
          else raise ::Leftovers::ConfigError, "Unrecognized type #{type}"
          end
        end

        matcher = ::Leftovers::MatcherBuilders::Or.build(types, nil)

        return ::Leftovers::Matchers::NodeType.new(matcher) if matcher

        ::Leftovers::MatcherBuilders::Fallback.build(default)
      end
    end
  end
end

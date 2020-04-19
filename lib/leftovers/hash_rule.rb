# frozen_string_literal: true

require 'set'
require_relative 'value_rule'
require_relative 'name_rule'

module Leftovers
  class HashRule
    def initialize(patterns) # rubocop:disable Metrics/MethodLength, Metrics/CyclomaticComplexity, Metrics/AbcSize, Metrics/PerceivedComplexity
      keys = []
      pairs = []
      Leftovers.each_or_self(patterns) do |pat|
        if pat.is_a?(Hash) && pat[:value]
          pairs << [
            (NameRule.new(pat[:keyword]) if pat[:keyword]),
            (ValueRule.new(pat[:value]) if pat[:value])
          ]
        else
          keys << NameRule.new(pat)
        end
      end

      @keys = (NameRule.new(keys) if keys)

      @pairs = (pairs unless pairs.empty?)

      freeze
    end

    def match_pair?(key_node, value_node)
      return true if @keys&.match?(key_node.to_sym, key_node.to_s)

      @pairs&.any? do |(key_rule, value_rule)|
        next unless !key_rule || key_rule.match?(key_node.to_sym, key_node.to_s)

        (!value_rule || value_rule.match?(value_node))
      end
    end
  end
end

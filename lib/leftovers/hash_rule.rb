# frozen_string_literal: true

require 'set'
require_relative 'value_rule'
require_relative 'name_rule'

module Leftovers
  class HashRule
    def initialize(patterns) # rubocop:disable Metrics/MethodLength, Metrics/CyclomaticComplexity, Metrics/AbcSize
      keys = Set.new.compare_by_identity
      pairs = []
      Array.each_or_self(patterns) do |pat|
        case pat
        when String
          keys.merge(pat.split(/\s+/).map(&:to_sym))
        when Hash
          pairs << [
            (NameRule.new(pat[:keyword]) if pat[:keyword]),
            (ValueRule.new(pat[:value]) if pat[:value])
          ]
        end
      end

      case keys.length
      when 0 then nil
      when 1
        @key = keys.first
      else
        @keys = keys
      end

      @pairs = pairs unless pairs.empty?

      freeze
    end

    def match_pair?(key_node, value_node) # rubocop:disable Metrics/MethodLength
      return true if @key&.== key_node.to_sym
      return true if @keys&.include? key_node.to_sym

      @pairs&.any? do |(key_rule, value_rule)|
        next unless !key_rule || key_rule.match?(key_node.to_sym, key_node.to_s)

        (!value_rule || value_rule.match?(value_node))
      end
    end
  end
end

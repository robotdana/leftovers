# frozen_string_literal: true

require 'set'
require_relative 'value_rule'
require_relative 'matchers/name_builder'

module Leftovers
  class HashRule
    # :nocov:
    using ::Leftovers::SetCaseEq if defined?(::Leftovers::SetCaseEq)
    # :nocov:

    def initialize(patterns) # rubocop:disable Metrics/MethodLength
      keys = []
      pairs = []
      Leftovers.each_or_self(patterns) do |pat|
        if pat.is_a?(Hash) && pat[:value]
          pairs << [
            ::Leftovers::Matchers::NameBuilder.build(pat[:keyword] || pat[:index]),
            ValueRule.new(pat[:value])
          ]
        else
          keys << ::Leftovers::Matchers::NameBuilder.build(pat)
        end
      end

      @keys = ::Leftovers::Matchers::NameBuilder.build(keys, false)

      @pairs = (pairs unless pairs.empty?)

      freeze
    end

    def match_pair?(key, value_node)
      return true if @keys === key

      @pairs&.any? do |(key_rule, value_rule)|
        key_rule === key && value_rule.match?(value_node)
      end
    end
  end
end

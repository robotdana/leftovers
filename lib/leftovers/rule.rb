# frozen_string_literal: true

require_relative 'matcher_builders/rule'
require_relative 'argument_rule'
require 'fast_ignore'

module Leftovers
  class Rule
    # :nocov:
    using ::Leftovers::SetCaseEq if defined?(::Leftovers::SetCaseEq)
    # :nocov:

    def self.wrap(rules)
      case rules
      when Array then rules.flat_map { |r| wrap(r) }
      when nil then [].freeze
      else new(**rules)
      end
    end

    attr_reader :skip
    alias_method :skip?, :skip

    def initialize( # rubocop:disable Metrics/MethodLength, Metrics/AbcSize
      call: nil,
      skip: false,
      define: nil,
      **matcher_args
    )
      @matcher = ::Leftovers::MatcherBuilders::Rule.build(**matcher_args)

      @skip = skip

      begin
        @calls = ArgumentRule.wrap(call)
      rescue ArgumentError, Leftovers::ConfigError => e
        raise e, "#{e.message} for calls", e.backtrace
      end

      begin
        @defines = ArgumentRule.wrap(define, definer: true)
      rescue ArgumentError, Leftovers::ConfigError => e
        raise e, "#{e.message} for defines", e.backtrace
      end
    rescue ArgumentError, Leftovers::ConfigError => e
      names = Array(matcher_args[:names]).map(&:to_s).join(', ')
      raise e, "#{e.message} for #{names}", e.backtrace
    end

    def match?(node)
      @matcher === node
    end

    def calls(node)
      @calls.flat_map { |m| m.matches(node) }
    end

    def definitions(node)
      @defines.flat_map { |m| m.matches(node) }
    end
  end
end

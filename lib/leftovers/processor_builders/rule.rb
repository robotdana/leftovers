# frozen-string-literal: true

require_relative 'each_rule'
require_relative 'action'
require_relative '../matcher_builders/rule'
require_relative '../rule_processors/call'
require_relative '../rule_processors/call_definition'
require_relative '../rule_processors/definition'
require_relative '../rule_processors/null'

module Leftovers
  module ProcessorBuilders
    module Rule
      def self.build(rules) # rubocop:disable Metrics/MethodLength
        ::Leftovers::ProcessorBuilders::EachRule.each_or_self(rules) do |rule|
          call = ::Leftovers::ProcessorBuilders::Action.build(rule.delete(:call), :call)
          definition = ::Leftovers::ProcessorBuilders::Action.build(rule.delete(:define), :define)
          matcher = ::Leftovers::MatcherBuilders::Rule.build(**rule) if call || definition

          # this nonsense saves a method call and array instantiation per method
          if call && definition
            ::Leftovers::RuleProcessors::CallDefinition.new(matcher, call, definition)
          elsif definition
            ::Leftovers::RuleProcessors::Definition.new(matcher, definition)
          elsif call
            ::Leftovers::RuleProcessors::Call.new(matcher, call)
          else
            ::Leftovers::RuleProcessors::Null
          end
        end
      end
    end
  end
end

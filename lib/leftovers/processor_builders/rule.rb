# frozen-string-literal: true

module Leftovers
  module ProcessorBuilders
    module Rule
      def self.build(rules) # rubocop:disable Metrics/MethodLength
        ::Leftovers::ProcessorBuilders::EachRule.each_or_self(rules) do |rule|
          call = ::Leftovers::ProcessorBuilders::Action.build(rule.delete(:call), :call)
          definition = ::Leftovers::ProcessorBuilders::Action.build(rule.delete(:define), :define)
          matcher = ::Leftovers::MatcherBuilders::Rule.build(**rule)

          # this nonsense saves a method call and array instantiation per method
          if call && definition
            ::Leftovers::RuleProcessors::CallDefinition.new(matcher, call, definition)
          elsif definition
            ::Leftovers::RuleProcessors::Definition.new(matcher, definition)
          elsif call
            ::Leftovers::RuleProcessors::Call.new(matcher, call)
          # :nocov:
          else raise
            # :nocov:
          end
        end
      end
    end
  end
end

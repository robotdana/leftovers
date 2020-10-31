# frozen-string-literal: true

module Leftovers
  module ProcessorBuilders
    module Dynamic
      def self.build(dynamic_rules) # rubocop:disable Metrics/MethodLength
        ::Leftovers::ProcessorBuilders::EachDynamic.each_or_self(dynamic_rules) do |dynamic|
          call = ::Leftovers::ProcessorBuilders::Action.build(dynamic.delete(:call), :call)
          define = ::Leftovers::ProcessorBuilders::Action.build(dynamic.delete(:define), :define)
          matcher = ::Leftovers::MatcherBuilders::Dynamic.build(**dynamic)

          # this nonsense saves a method call and array instantiation per method
          if call && define
            ::Leftovers::DynamicProcessors::CallDefinition.new(matcher, call, define)
          elsif define
            ::Leftovers::DynamicProcessors::Definition.new(matcher, define)
          elsif call
            ::Leftovers::DynamicProcessors::Call.new(matcher, call)
          # :nocov:
          else raise
            # :nocov:
          end
        end
      end
    end
  end
end

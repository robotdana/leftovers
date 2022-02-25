# frozen-string-literal: true

module Leftovers
  module ProcessorBuilders
    module Dynamic
      class << self
        def build(dynamic_rules)
          ::Leftovers::ProcessorBuilders::EachDynamic.each_or_self(dynamic_rules) do |dynamic|
            build_processors(**dynamic)
          end
        end

        private

        def build_processors(
          call: nil, define: nil, set_privacy: nil, set_default_privacy: nil, **matcher_rules
        )
          matcher = ::Leftovers::MatcherBuilders::Node.build(**matcher_rules)

          call_action = build_action(call, return_type: :sym)
          define_action = build_action(define, return_type: :definition_node)

          ::Leftovers::ProcessorBuilders::EachDynamic.build([
            build_call_define_processor(matcher, call_action, define_action),
            build_set_privacy_processor(matcher, set_privacy),
            build_set_default_privacy_processor(matcher, set_default_privacy)
          ])
        end

        def build_action(processor_rules, return_type:)
          ::Leftovers::ProcessorBuilders::Action.build(processor_rules, return_type)
        end

        def build_set_privacy_processor(matcher, set_privacy)
          ::Leftovers::ProcessorBuilders::EachDynamic.each_or_self(set_privacy) do |action_values|
            to = action_values.delete(:to)
            action = build_action(action_values, return_type: :sym)

            ::Leftovers::DynamicProcessors::SetPrivacy.new(matcher, action, to)
          end
        end

        def build_set_default_privacy_processor(matcher, set_default_privacy)
          ::Leftovers::DynamicProcessors::SetDefaultPrivacy.new(matcher, set_default_privacy)
        end

        def build_call_define_processor(matcher, call_action, define_action)
          if call_action && define_action
            # this nonsense saves a method call and array instantiation per method
            ::Leftovers::DynamicProcessors::CallDefinition.new(matcher, call_action, define_action)
          elsif define_action
            ::Leftovers::DynamicProcessors::Definition.new(matcher, define_action)
          elsif call_action
            ::Leftovers::DynamicProcessors::Call.new(matcher, call_action)
          else
            ::Leftovers::DynamicProcessors::Null
          end
        end
      end
    end
  end
end

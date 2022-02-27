# frozen-string-literal: true

module Leftovers
  module ProcessorBuilders
    module Dynamic
      class << self
        def build(dynamic_rules)
          ::Leftovers::ProcessorBuilders::Each.each_or_self(dynamic_rules) do |dynamic|
            build_processors(**dynamic)
          end
        end

        private

        def build_processors(
          call: nil, define: nil, set_privacy: nil, set_default_privacy: nil, **matcher_rules
        )
          matcher = ::Leftovers::MatcherBuilders::Node.build(**matcher_rules)

          processor = ::Leftovers::ProcessorBuilders::Each.build([
            build_call_action(call),
            build_define_action(define),
            build_set_privacy_action(set_privacy),
            build_set_default_privacy_action(set_default_privacy)
          ])

          ::Leftovers::ValueProcessors::IfMatcher.new(matcher, processor)
        end

        def build_call_action(call)
          ::Leftovers::ProcessorBuilders::Action.build(
            call, ::Leftovers::ValueProcessors::AddCall
          )
        end

        def build_define_action(define)
          ::Leftovers::ProcessorBuilders::Action.build(
            define, ::Leftovers::ValueProcessors::AddDefinitionNode
          )
        end

        def build_set_privacy_action(set_privacies)
          ::Leftovers::ProcessorBuilders::Each.each_or_self(set_privacies) do |set_privacy|
            processor = ::Leftovers::ValueProcessors::SetPrivacy.new(set_privacy.delete(:to))
            ::Leftovers::ProcessorBuilders::Action.build_from_hash_value(
              **set_privacy, final_processor: processor
            )
          end
        end

        def build_set_default_privacy_action(set_default_privacy)
          return unless set_default_privacy

          ::Leftovers::ValueProcessors::SetDefaultPrivacy.new(set_default_privacy)
        end
      end
    end
  end
end

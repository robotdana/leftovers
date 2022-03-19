# frozen-string-literal: true

module Leftovers
  module ProcessorBuilders
    module Dynamic
      class << self
        def build(dynamic_rules)
          Each.each_or_self(dynamic_rules) do |dynamic|
            build_processors(**dynamic)
          end
        end

        private

        def build_processors( # rubocop:disable Metrics/ParameterLists
          call: nil, define: nil,
          set_privacy: nil, set_default_privacy: nil,
          eval: nil, **matcher_rules
        )
          matcher = MatcherBuilders::Node.build(**matcher_rules)

          processor = Each.build([
            build_call_action(call),
            build_define_action(define),
            build_set_privacy_action(set_privacy),
            build_set_default_privacy_action(set_default_privacy),
            build_eval_action(eval)
          ])

          Processors::MatchMatchedNode.new(matcher, processor)
        end

        def build_call_action(call)
          Action.build(call, Processors::AddCall)
        end

        def build_define_action(define)
          Action.build(define, Processors::AddDefinitionNode)
        end

        def build_eval_action(eval)
          Action.build(eval, Processors::Eval)
        end

        def build_set_privacy_action(set_privacies)
          Each.each_or_self(set_privacies) do |set_privacy|
            processor = Processors::SetPrivacy.new(set_privacy.delete(:to))
            Action.build_from_hash_value(
              **set_privacy, final_processor: processor
            )
          end
        end

        def build_set_default_privacy_action(set_default_privacy)
          return unless set_default_privacy

          Processors::SetDefaultPrivacy.new(set_default_privacy)
        end
      end
    end
  end
end

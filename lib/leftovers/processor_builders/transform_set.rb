# frozen-string-literal: true

module Leftovers
  module ProcessorBuilders
    module TransformSet
      class << self
        def build(transforms, action)
          each_builder(action).each_or_self(transforms) do |transform|
            case transform
            when ::Hash
              next build(transform[:transforms], action) if transform[:transforms]

              ::Leftovers::ProcessorBuilders::TransformChain.build(transform, build_final(action))
            when ::String
              ::Leftovers::ProcessorBuilders::TransformChain.build(transform, build_final(action))
            # :nocov:
            else raise Leftovers::UnexpectedCase, "Unhandled value #{transform.inspect}"
              # :nocov:
            end
          end
        end

        def build_final(action)
          case action
          when :sym
            ::Leftovers::ValueProcessors::ReturnSym
          when :definition_node
            ::Leftovers::ValueProcessors::ReturnDefinitionNode
          # :nocov:
          else raise Leftovers::UnexpectedCase, "Unhandled value #{action.inspect}"
            # :nocov:
          end
        end

        private

        def each_builder(action)
          case action
          when :sym
            ::Leftovers::ProcessorBuilders::Each
          when :definition_node
            ::Leftovers::ProcessorBuilders::EachForDefinitionSet
          # :nocov:
          else raise Leftovers::UnexpectedCase, "Unhandled value #{action.inspect}"
            # :nocov:
          end
        end
      end
    end
  end
end

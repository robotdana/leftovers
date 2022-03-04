# frozen-string-literal: true

module Leftovers
  module ProcessorBuilders
    module TransformSet
      class << self
        def build(transforms, final_processor)
          each_builder(final_processor).each_or_self(transforms) do |transform|
            case transform
            when ::Hash, ::String
              ::Leftovers::ProcessorBuilders::TransformChain.build(transform, final_processor)
            # :nocov:
            else raise Leftovers::UnexpectedCase, "Unhandled value #{transform.inspect}"
              # :nocov:
            end
          end
        end

        private

        def each_builder(final_processor)
          if final_processor == ::Leftovers::Processors::AddDefinitionNode
            ::Leftovers::ProcessorBuilders::EachForDefinitionSet
          else
            ::Leftovers::ProcessorBuilders::Each
          end
        end
      end
    end
  end
end

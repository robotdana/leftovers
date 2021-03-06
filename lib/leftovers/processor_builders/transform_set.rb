# frozen-string-literal: true

module Leftovers
  module ProcessorBuilders
    module TransformSet
      def self.build(transforms, action)
        each_builder(action).each_or_self(transforms) do |transform|
          case transform
          when ::Hash
            next build(transform[:transforms], action) if transform[:transforms]

            ::Leftovers::ProcessorBuilders::TransformChain.build(transform, build_final(action))
          when ::String
            ::Leftovers::ProcessorBuilders::TransformChain.build(transform, build_final(action))
          # :nocov:
          else raise
            # :nocov:
          end
        end
      end

      def self.each_builder(action)
        case action
        when :call
          ::Leftovers::ProcessorBuilders::Each
        when :define
          ::Leftovers::ProcessorBuilders::EachForDefinitionSet
        # :nocov:
        else raise
          # :nocov:
        end
      end

      def self.build_final(action)
        case action
        when :call
          ::Leftovers::ValueProcessors::ReturnString
        when :define
          ::Leftovers::ValueProcessors::ReturnDefinition
        # :nocov:
        else raise
          # :nocov:
        end
      end
    end
  end
end

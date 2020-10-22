# frozen-string-literal: true

require_relative 'each_value'
require_relative 'transform_chain'
require_relative '../value_processors/return_definition'
require_relative '../value_processors/return_call'

module Leftovers
  module ProcessorBuilders
    module TransformSet
      def self.build(transforms, action)
        ::Leftovers::ProcessorBuilders::EachValue.each_or_self(transforms, action) do |transform|
          case transform
          when ::Hash
            next build(transform[:transforms], action) if transform[:transforms]

            ::Leftovers::ProcessorBuilders::TransformChain.build(transform, build_final(action))
          when ::String
            ::Leftovers::ProcessorBuilders::TransformChain.build(transform, build_final(action))
          else raise
          end
        end
      end

      def self.build_final(action)
        case action
        when :call
          ::Leftovers::ValueProcessors::ReturnCall
        when :define
          ::Leftovers::ValueProcessors::ReturnDefinition
        else raise
        end
      end
    end
  end
end

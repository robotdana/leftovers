# frozen-string-literal: true

require_relative 'transform'

module Leftovers
  module ProcessorBuilders
    module TransformChain
      def self.build(transforms, next_transform) # rubocop:disable Metrics/MethodLength
        case transforms
        when ::Array
          transforms.reverse_each do |transform|
            next_transform = ::Leftovers::ProcessorBuilders::Transform.build(
              transform, nil, next_transform
            )
          end
          next_transform
        when ::Hash
          transforms.reverse_each do |(transform, transform_arg)|
            next_transform = ::Leftovers::ProcessorBuilders::Transform.build(
              transform, transform_arg, next_transform
            )
          end
          next_transform
        else
          ::Leftovers::ProcessorBuilders::Transform.build(transforms, nil, next_transform)
        end
      end
    end
  end
end

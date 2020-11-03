# frozen-string-literal: true

module Leftovers
  module ProcessorBuilders
    module TransformChain
      def self.build(transforms, next_transform) # rubocop:disable Metrics/MethodLength
        case transforms
        when ::Hash
          transforms.reverse_each do |(transform, transform_arg)|
            next_transform = ::Leftovers::ProcessorBuilders::Transform.build(
              transform, transform_arg, next_transform
            )
          end
          next_transform
        when ::String
          ::Leftovers::ProcessorBuilders::Transform.build(transforms, true, next_transform)
        # :nocov:
        else raise
          # :nocov:
        end
      end
    end
  end
end

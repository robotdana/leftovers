# frozen-string-literal: true

module Leftovers
  module ProcessorBuilders
    module TransformChain
      class << self
        def build(transforms, next_transform)
          case transforms
          when ::Hash then build_from_hash(transforms, next_transform)
          when ::String
            ::Leftovers::ProcessorBuilders::Transform.build(transforms, true, next_transform)
          # :nocov:
          else raise Leftovers::UnexpectedCase, "Unhandled value #{transforms.inspect}"
            # :nocov:
          end
        end

        private

        def build_from_hash(transforms, next_transform)
          transforms.reverse_each do |(transform, transform_arg)|
            next_transform = ::Leftovers::ProcessorBuilders::Transform.build(
              transform, transform_arg, next_transform
            )
          end

          next_transform
        end
      end
    end
  end
end

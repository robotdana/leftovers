# frozen-string-literal: true

# This is the only builder allowed to return nil
require_relative '../matchers/anything'
require_relative '../matchers/nothing'

module Leftovers
  module Builders
    module FallbackMatcher
      def self.build(default) # rubocop:disable Metrics/MethodLength
        case default
        when true then ::Leftovers::Matchers::Anything
        when false then ::Leftovers::Matchers::Nothing
        when nil then nil
        else raise ArgumentError, 'Fallback must be true, false, or nil'
        end
      end
    end
  end
end

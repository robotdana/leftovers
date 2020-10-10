# frozen-string-literal: true

require_relative 'fallback_matcher'
require_relative 'name_matcher'
require_relative '../matchers/node_name'

module Leftovers
  module Builders
    module NodeNameMatcher
      def self.build(name_pattern, default = true)
        matcher = ::Leftovers::Builders::NameMatcher.build(name_pattern, nil)
        return ::Leftovers::Matchers::NodeName.new(matcher) if matcher

        ::Leftovers::Builders::FallbackMatcher.build(default)
      end
    end
  end
end

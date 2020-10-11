# frozen-string-literal: true

require_relative 'fallback'
require_relative 'name'
require_relative '../matchers/node_name'

module Leftovers
  module MatcherBuilders
    module NodeName
      def self.build(name_pattern, default = true)
        matcher = ::Leftovers::MatcherBuilders::Name.build(name_pattern, nil)
        return ::Leftovers::Matchers::NodeName.new(matcher) if matcher

        ::Leftovers::MatcherBuilders::Fallback.build(default)
      end
    end
  end
end

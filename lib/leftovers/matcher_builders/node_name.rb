# frozen-string-literal: true

require_relative 'name'
require_relative '../matchers/node_name'

module Leftovers
  module MatcherBuilders
    module NodeName
      def self.build(name_pattern)
        matcher = ::Leftovers::MatcherBuilders::Name.build(name_pattern)
        return unless matcher

        ::Leftovers::Matchers::NodeName.new(matcher)
      end
    end
  end
end

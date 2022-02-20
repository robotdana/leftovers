# frozen-string-literal: true

module Leftovers
  module MatcherBuilders
    module NodePrivacy
      def self.build(privacy_settings)
        ::Leftovers::MatcherBuilders::Or.each_or_self(privacy_settings) do |privacy|
          ::Leftovers::Matchers::NodePrivacy.new(privacy)
        end
      end
    end
  end
end

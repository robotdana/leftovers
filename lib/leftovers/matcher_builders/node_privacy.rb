# frozen_string_literal: true

module Leftovers
  module MatcherBuilders
    module NodePrivacy
      def self.build(privacy_settings)
        Or.each_or_self(privacy_settings) do |privacy|
          Matchers::NodePrivacy.new(privacy)
        end
      end
    end
  end
end

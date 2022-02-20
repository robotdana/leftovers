# frozen_string_literal: true

module Leftovers
  module Matchers
    class NodePrivacy
      def initialize(privacy_matcher)
        @privacy_matcher = privacy_matcher

        freeze
      end

      def ===(node)
        @privacy_matcher === node.privacy
      end

      freeze
    end
  end
end

# frozen_string_literal: true

module Leftovers
  module Matchers
    class Predicate
      def initialize(predicate)
        @predicate = predicate

        freeze
      end

      def ===(node)
        node.send(@predicate)
      end

      freeze
    end
  end
end

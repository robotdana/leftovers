# frozen_string_literal: true

module Leftovers
  module Matchers
    class All
      attr_reader :matchers

      def initialize(matchers)
        @matchers = matchers

        freeze
      end

      def ===(value)
        @matchers.all? do |matcher|
          matcher === value
        end
      end

      freeze
    end
  end
end

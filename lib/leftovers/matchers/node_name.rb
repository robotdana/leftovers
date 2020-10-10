# frozen_string_literal: true

module Leftovers
  module Matchers
    class NodeName
      # :nocov:
      using ::Leftovers::SetCaseEq if defined?(::Leftovers::SetCaseEq)
      # :nocov:

      def initialize(name_matcher)
        @name_matcher = name_matcher

        freeze
      end

      def ===(node)
        @name_matcher === node.name
      end

      freeze
    end
  end
end

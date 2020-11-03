# frozen_string_literal: true

module Leftovers
  module Matchers
    class NodeType
      # :nocov:
      using ::Leftovers::Backports::SetCaseEq if defined?(::Leftovers::Backports::SetCaseEq)
      # :nocov:

      def initialize(type_matcher)
        @type_matcher = type_matcher

        freeze
      end

      def ===(node)
        @type_matcher === node.type
      end

      freeze
    end
  end
end

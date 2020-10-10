# frozen_string_literal: true

module Leftovers
  module Matchers
    class Send
      # :nocov:
      using ::Leftovers::SetCaseEq if defined?(::Leftovers::SetCaseEq)
      # :nocov:

      def initialize(name_matcher, path_matcher)
        @node_name_matcher = name_matcher
        @node_path_matcher = path_matcher

        freeze
      end

      def ===(node)
        (@node_name_matcher === node) &&
          (@node_path_matcher === node)
      end

      freeze
    end
  end
end

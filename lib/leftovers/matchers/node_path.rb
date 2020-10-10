# frozen_string_literal: true

module Leftovers
  module Matchers
    class NodePath
      def initialize(path_matcher)
        @path_matcher = path_matcher

        freeze
      end

      def ===(node)
        @path_matcher === node.path
      end

      freeze
    end
  end
end

# frozen_string_literal: true

module Leftovers
  module Matchers
    class Path
      include ComparableInstance

      def initialize(fast_ignore)
        @fast_ignore = fast_ignore

        freeze
      end

      def ===(path)
        @fast_ignore.allowed?(path, exists: true, directory: false)
      end

      freeze
    end
  end
end

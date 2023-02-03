# frozen_string_literal: true

module Leftovers
  class FileCollector
    class NodeProcessor
      class Error < ::Leftovers::FileCollector::Error
        attr_reader :node

        def initialize(message, node)
          super(message)
          @node = node
        end
      end
    end
  end
end

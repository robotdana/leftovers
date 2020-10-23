# frozen_string_literal: true

require 'parser'

module Leftovers
  module AST
    class Builder < ::Parser::Builders::Default
      # Generates {Node} from the given information.
      #
      # @return [Node] the generated node

      def n(type, children, source_map)
        ::Leftovers::AST::Node.new(type, children, location: source_map)
      end

      # Don't complain about invalid strings
      def string_value(token)
        value(token)
      end
    end
  end
end

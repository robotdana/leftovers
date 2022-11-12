# frozen_string_literal: true

require 'set'

module Leftovers
  module MatcherBuilders
    module NodeType
      def self.build(types_pattern) # rubocop:disable Metrics
        Or.each_or_self(types_pattern) do |type|
          case type
          when :Symbol then Matchers::NodeType.new(:sym)
          when :String then Matchers::NodeType.new(:str)
          when :Integer then Matchers::NodeType.new(:int)
          when :Float then Matchers::NodeType.new(:float)
          when :Array then Matchers::NodeType.new(:array)
          when :Hash then Matchers::NodeType.new(:hash)
          when :Proc then Matchers::NodeIsProc
          when :Method then Matchers::NodeType.new(::Set[:send, :csend, :def, :defs].compare_by_identity.freeze)
          when :Constant then Matchers::NodeType.new(::Set[:const, :class, :module, :casgn].compare_by_identity.freeze)
          # :nocov:
          else raise UnexpectedCase, "Unhandled value #{type.inspect}"
            # :nocov:
          end
        end
      end
    end
  end
end

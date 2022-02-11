# frozen_string_literal: true

module Leftovers
  module MatcherBuilders
    module Document
      def self.build(true_arg)
        return unless true_arg

        ::Leftovers::Matchers::NodeName.new(:__leftovers_document)
      end
    end
  end
end

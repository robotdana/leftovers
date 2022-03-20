# frozen_string_literal: true

module Leftovers
  module MatcherBuilders
    module Document
      def self.build(true_arg)
        Matchers::NodeName.new(:__leftovers_document) if true_arg
      end
    end
  end
end

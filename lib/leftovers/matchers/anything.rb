# frozen_string_literal: true

module Leftovers
  module Matchers
    module Anything
      def self.===(_value)
        true
      end
    end
  end
end

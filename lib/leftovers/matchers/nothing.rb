# frozen_string_literal: true

module Leftovers
  module Matchers
    module Nothing
      def self.===(_value)
        false
      end

      freeze
    end
  end
end

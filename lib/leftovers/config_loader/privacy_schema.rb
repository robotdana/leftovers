# frozen_string_literal: true

module Leftovers
  class ConfigLoader
    class PrivacySchema < StringEnumSchema
      value :public
      value :protected
      value :private

      def self.to_ruby(node)
        super.to_sym
      end
    end
  end
end

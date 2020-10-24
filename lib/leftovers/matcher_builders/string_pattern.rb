# frozen_string_literal: true

module Leftovers
  module MatcherBuilders
    module StringPattern
      def self.build(match: nil, has_prefix: nil, has_suffix: nil)
        if match
          /\A#{match}\z/
        elsif has_prefix && has_suffix
          /\A#{::Regexp.escape(has_prefix)}.*#{::Regexp.escape(has_suffix)}\z/
        elsif has_prefix
          /\A#{::Regexp.escape(has_prefix)}/
        elsif has_suffix
          /#{::Regexp.escape(has_suffix)}\z/
        # :nocov:
        else raise
          # :nocov:
        end
      end
    end
  end
end

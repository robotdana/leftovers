# frozen_string_literal: true

module Leftovers
  module MatcherBuilders
    module StringPattern
      def self.build(match: nil, has_prefix: nil, has_suffix: nil) # rubocop:disable Metrics
        has_prefix = ::Regexp.escape(has_prefix) if has_prefix
        has_suffix = ::Regexp.escape(has_suffix) if has_suffix

        if match && has_prefix && has_suffix
          /\A(?=#{match}\z)(?=#{has_prefix}).*#{has_suffix}\z/
        elsif match && has_prefix
          /\A(?=#{match}\z)#{has_prefix}/
        elsif match && has_suffix
          /\A(?=#{match}\z).*#{has_suffix}\z/
        elsif match
          /\A#{match}\z/
        elsif has_prefix && has_suffix
          /\A(?=#{has_prefix}).*#{has_suffix}\z/
        elsif has_prefix
          /\A#{has_prefix}/
        elsif has_suffix
          /#{has_suffix}\z/
        else
          nil
        end
      end
    end
  end
end

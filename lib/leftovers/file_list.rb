# frozen_string_literal: true

require 'fast_ignore'
require_relative 'file'

module Leftovers
  class FileList
    include Enumerable

    def each # rubocop:disable Metrics/MethodLength
      FastIgnore.new(
        ignore_rules: Leftovers.config.exclude_paths,
        include_rules: Leftovers.config.include_paths,
        include_shebangs: ['ruby']
      ).each do |file|
        yield(Leftovers::File.new(file))
      end
    end

    def to_a
      enum_for(:each).to_a
    end
  end
end

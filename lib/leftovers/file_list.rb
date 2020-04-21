# frozen_string_literal: true

require 'fast_ignore'
require_relative 'file'

module Leftovers
  class FileList
    include Enumerable

    def each
      fast_ignore.each do |file|
        yield(Leftovers::File.new(file))
      end
    end

    def to_a
      enum_for(:each).to_a
    end

    def fast_ignore
      FastIgnore.new(
        ignore_rules: Leftovers.config.exclude_paths,
        include_rules: ['#!:ruby'] + Leftovers.config.include_paths
      )
    end
  end
end

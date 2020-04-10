# frozen_string_literal: true

require 'fast_ignore'

module Leftovers
  class FileList
    include Enumerable

    def ruby_hashbang?(file)
      return unless File.extname(file).empty?

      return if File.empty?(file)

      File.foreach(file).first&.chomp&.match(%r{\A#!.*\bruby$})
    rescue ArgumentError, Errno::ENOENT
      # if it's a binary file we can't open it
    end

    def each
      FastIgnore.new(ignore_rules: Leftovers.config.exclude_paths, include_rules: Leftovers.config.include_paths).each do |file|
        next if File.extname(file).empty? && !ruby_hashbang?(file)
        yield(file)
      end
    end

    def to_a
      enum_for(:each).to_a
    end
  end
end

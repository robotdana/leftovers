# frozen_string_literal: true

require 'fast_ignore'

module Forgotten
  class FileList
    include Enumerable

    def root
      @root ||= Dir.pwd
    end

    def fnmatch?(pattern, file)
      File.fnmatch?(pattern, file.delete_prefix(root + '/'), File::FNM_DOTMATCH)
    end

    def ruby_hashbang?(file)
      return unless File.extname(file).empty?

      return if File.empty?(file)

      File.foreach(file).first&.chomp&.match(%r{\A#!.*\bruby$})
    rescue ArgumentError, Errno::ENOENT
      # if it's a binary file we can't open it
    end

    def each
      FastIgnore.new(ignore_rules: Forgotten.config.excludes, include_rules: Forgotten.config.includes).each do |file|
        yield(file)
      end

      FastIgnore.new(ignore_rules: '*.*').each do |file|
        next unless ruby_hashbang?(file)
        yield(file)
      end
    end

    def to_a
      enum_for(:each).to_a
    end
  end
end

# frozen_string_literal: true

require 'fast_ignore'

module Forgotten
  class FileList
    include Enumerable

    def initialize(*patterns)
      @patterns = patterns
    end

    def root
      @root ||= Dir.pwd
    end

    def fnmatch?(pattern, file)
      File.fnmatch?(pattern, file.delete_prefix(root + '/'), File::FNM_DOTMATCH)
    end

    def config_only?(file)
      Forgotten.config.only.empty? || Forgotten.config.only.any? { |o| fnmatch?(o, file) }
    end

    def ruby_hashbang?(file)
      return unless File.extname(file).empty?

      File.foreach(file).first.chomp =~ %r{\A#!.*\bruby$}
    end

    def each
      # TODO: handle no gitignore
      gitignore = File.join(Dir.pwd, '.gitignore')
      gitignore = nil unless File.exist?(gitignore)
      FastIgnore.new(rules: Forgotten.config.ignored, gitignore: gitignore).each do |file|
        next unless config_only?(file) || ruby_hashbang?(file)
        yield(file)
      end
    end

    def to_a
      enum_for(:each).to_a
    end
  end
end

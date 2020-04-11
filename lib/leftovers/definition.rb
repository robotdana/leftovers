# frozen_string_literal: true

module Leftovers
  class Definition
    attr_reader :name
    attr_reader :location
    attr_accessor :filename
    attr_accessor :group
    alias_method :group?, :group
    attr_accessor :test
    alias_method :test?, :test

    def self.wrap(strings, location, filename: nil, test: false, link: false)
      strings.each.with_object([]) do |string, group|
        d = new(string, location, filename: filename, test: test)
        group << d
        d.group = group if link
      end
    end

    def initialize(name, location, filename: nil, test: false)
      @name = name
      @location = location
      @filename = filename
      @test = test
    end

    def <=>(other)
      (filename <=> other.filename).nonzero? ||
        (line <=> other.line).nonzero? ||
        (column <=> other.column)
    end

    def line
      location.line
    end

    def column
      location.column
    end

    def name_s
      @name_s ||= name.to_s.freeze
    end
    alias_method :to_s, :name_s

    def full_location
      "#{filename}:#{location.line}:#{location.column}"
    end

    def highlighted_source(highlight = "\e[31m", normal = "\e[0m") # rubocop:disable Metrics/AbcSize
      location.source_line.to_s[0...(location.column_range.begin)].lstrip +
        highlight + location.source.to_s + normal +
        location.source_line.to_s[(location.column_range.end)..-1].rstrip
    end

    def any_in_collection?
      if group?
        group.any?(&:in_collection?)
      else
        in_collection?
      end
    end

    def in_collection? # rubocop:disable Metrics/MethodLength
      return @in_collection if defined?(@in_collection)

      @in_collection = if test?
        Leftovers.collector.calls.include?(name) || in_test_collection?
      else
        Leftovers.collector.calls.include?(name)
      end
    end

    def any_in_test_collection?
      if group?
        group.any?(&:in_test_collection?)
      else
        in_collection?
      end
    end

    def in_test_collection?
      return @in_test_collection if defined?(@in_test_collection)

      @in_test_collection = Leftovers.collector.test_calls.include?(name)
    end

    def any_skipped?
      if group?
        group.any?(&:skipped?)
      else
        skipped?
      end
    end

    def skipped?
      return @skipped if defined?(@skipped)

      @skipped = Leftovers.config.skip_rules.any? { |r| r.match?(name_s, filename) }
    end
  end
end

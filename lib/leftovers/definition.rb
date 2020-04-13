# frozen_string_literal: true

module Leftovers
  class Definition
    attr_reader :filename
    attr_reader :name
    alias_method :names, :name
    alias_method :full_name, :name
    attr_reader :name_s
    alias_method :to_s, :name_s
    attr_reader :test
    alias_method :test?, :test

    def initialize( # rubocop:disable Metrics/MethodLength
      name,
      method_node: nil,
      location: method_node.loc.expression,
      filename: method_node.filename,
      test: method_node.test?
    )
      @name = name
      @name_s = name.to_s.freeze

      @location = location
      @filename = filename
      @test = test

      freeze
    end

    def <=>(other)
      (filename <=> other.filename).nonzero? ||
        (line <=> other.line).nonzero? ||
        (column <=> other.column)
    end

    def line
      @location.line
    end

    def column
      @location.column
    end

    def full_location
      "#{filename}:#{@location.line}:#{@location.column}"
    end

    def highlighted_source(highlight = "\e[31m", normal = "\e[0m") # rubocop:disable Metrics/AbcSize
      @location.source_line.to_s[0...(@location.column_range.begin)].lstrip +
        highlight + @location.source.to_s + normal +
        @location.source_line.to_s[(@location.column_range.end)..-1].rstrip
    end

    def in_collection?
      Leftovers.collector.calls.include?(@name) || (@test && in_test_collection?)
    end

    def in_test_collection?
      Leftovers.collector.test_calls.include?(@name)
    end

    def skipped?
      Leftovers.config.skip_rules.any? { |r| r.match?(@name, @name_s, filename) }
    end
  end
end

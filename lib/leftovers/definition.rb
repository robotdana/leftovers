# frozen_string_literal: true

module Leftovers
  class Definition
    attr_reader :name, :test, :location_s, :source_line
    alias_method :names, :name

    alias_method :test?, :test

    def initialize(
      name,
      location: method_node.loc.expression,
      test: method_node.test_line? || ::Leftovers.config.test_only === method_node
    )
      @name = name
      @path = location.source_buffer.name.to_s
      @source_line = location.source_line.to_s
      @location_column_range_begin = location.column_range.begin.to_i
      @location_column_range_end = location.column_range.end.to_i
      @location_source = location.source.to_s
      @location_s = location.to_s
      @test = test

      freeze
    end

    def to_s
      @name.to_s
    end

    def highlighted_source(highlight = "\e[31m", normal = "\e[0m")
      @source_line[0...@location_column_range_begin].lstrip +
        highlight + @location_source + normal +
        @source_line[@location_column_range_end..-1].rstrip
    end

    def in_collection?
      Leftovers.collector.calls.include?(@name) || (@test && in_test_collection?)
    end

    def in_test_collection?
      Leftovers.collector.test_calls.include?(@name)
    end
  end
end

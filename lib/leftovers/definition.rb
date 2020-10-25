# frozen_string_literal: true

module Leftovers
  class Definition
    attr_reader :name, :test, :location, :location_s
    alias_method :names, :name

    alias_method :test?, :test

    def initialize(
      name,
      method_node: nil,
      location: method_node.loc.expression,
      test: method_node.test?
    )
      @name = name
      @location = location
      @location_s = location.to_s
      @test = test

      freeze
    end

    def to_s
      @name.to_s
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
  end
end
